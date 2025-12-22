import Foundation
import CoreLocation
import MapKit

class RouteCalculator {
    static let shared = RouteCalculator()
    
    // Access Data from the Managers
    var allRoutes: [BusRoute] { return RouteManager.shared.allRoutes }
    var allStops: [BusStop] { return StopManager.shared.allStops }
    
    // MARK: - Find Nearest Stop
    func findNearestStop(to userLocation: CLLocation) -> BusStop? {
        return allStops.min { stop1, stop2 in
            let loc1 = CLLocation(latitude: stop1.coordinate.latitude, longitude: stop1.coordinate.longitude)
            let loc2 = CLLocation(latitude: stop2.coordinate.latitude, longitude: stop2.coordinate.longitude)
            return userLocation.distance(from: loc1) < userLocation.distance(from: loc2)
        }
    }
    
    // MARK: - LOGIC: Smart Route Finder
    func findRoute(from start: BusStop, to end: BusStop) async -> RouteResult? {
        
        // 1. Direct Route
        for route in allRoutes {
            // This will now only return true if the route is going the CORRECT direction
            if let pathStops = getStopsBetween(start: start, end: end, in: route) {
                return await createSmartDirectResult(route: route, pathStops: pathStops, start: start, end: end)
            }
        }
        
        // 2. Interchange (Simplified)
        for routeA in allRoutes where routeA.stops.contains(start) {
            for routeB in allRoutes where routeB.stops.contains(end) {
                let commonStops = Set(routeA.stops).intersection(Set(routeB.stops))
                if let transferStop = commonStops.first {
                    return await createTransferResult(routeA: routeA, routeB: routeB, start: start, transfer: transferStop, end: end)
                }
            }
        }
        return nil
    }
    
    // MARK: - HELPER: Extract specific stops (STRICT DIRECTION)
    private func getStopsBetween(start: BusStop, end: BusStop, in route: BusRoute) -> [BusStop]? {
        guard let startIndex = route.stops.firstIndex(of: start),
              let endIndex = route.stops.firstIndex(of: end) else { return nil }
        
        // FIX: STRICT ONE-WAY LOGIC
        // If startIndex < endIndex, we are moving forward (Correct).
        // If startIndex > endIndex, we are moving backward (Wrong Route).
        if startIndex < endIndex {
            return Array(route.stops[startIndex...endIndex])
        } else {
            // Return nil. This forces the loop to check the NEXT route (the DOWN route)
            return nil
        }
    }

    // MARK: - HELPER: Build Geometry
    private func createSmartDirectResult(route: BusRoute, pathStops: [BusStop], start: BusStop, end: BusStop) async -> RouteResult {
        
        var fullPathCoordinates: [CLLocationCoordinate2D] = []
        
        for i in 0..<(pathStops.count - 1) {
            let segmentStart = pathStops[i]
            let segmentEnd = pathStops[i+1]
            
            let segmentCoords = await getRoadGeometry(from: segmentStart.coordinate, to: segmentEnd.coordinate)
            fullPathCoordinates.append(contentsOf: segmentCoords)
        }
        
        let segment = RouteSegment(
            routeNumber: route.routeNumber,
            fromStop: start,
            toStop: end,
            pathCoordinates: fullPathCoordinates,
            colorHex: route.colorHex
        )
        
        return RouteResult(totalStops: pathStops.count, segments: [segment])
    }
    
    private func createTransferResult(routeA: BusRoute, routeB: BusRoute, start: BusStop, transfer: BusStop, end: BusStop) async -> RouteResult {
        async let path1 = getRoadGeometry(from: start.coordinate, to: transfer.coordinate)
        async let path2 = getRoadGeometry(from: transfer.coordinate, to: end.coordinate)
        let (road1, road2) = await (path1, path2)
        
        let seg1 = RouteSegment(routeNumber: routeA.routeNumber, fromStop: start, toStop: transfer, pathCoordinates: road1, colorHex: routeA.colorHex)
        let seg2 = RouteSegment(routeNumber: routeB.routeNumber, fromStop: transfer, toStop: end, pathCoordinates: road2, colorHex: routeB.colorHex)
        return RouteResult(totalStops: 0, segments: [seg1, seg2])
    }
    
    // MARK: - API CALL
    private func getRoadGeometry(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) async -> [CLLocationCoordinate2D] {
        let request = MKDirections.Request()
        request.source = MKMapItem(location: CLLocation(latitude: start.latitude, longitude: start.longitude), address: nil)
        request.destination = MKMapItem(location: CLLocation(latitude: end.latitude, longitude: end.longitude), address: nil)
        request.transportType = .walking
        
        // Optimization
        if abs(start.latitude - end.latitude) < 0.0005 && abs(start.longitude - end.longitude) < 0.0005 {
            return [start, end]
        }

        do {
            let directions = MKDirections(request: request)
            let response = try await directions.calculate()
            return response.routes.first?.polyline.coordinates ?? [start, end]
        } catch {
            return [start, end]
        }
    }
}

// Extension
extension MKPolyline {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        return coords
    }
}
