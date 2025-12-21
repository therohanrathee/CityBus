import Foundation
import CoreLocation
import MapKit

class RouteCalculator {
    static let shared = RouteCalculator()
    
    // MARK: - Data Access
    // We fetch the data from your other new files
    var allRoutes: [BusRoute] {
        return RouteManager.shared.allRoutes
    }
    
    var allStops: [BusStop] {
        return StopManager.shared.allStops
    }
    
    // MARK: - LOGIC: Find Route
    func findRoute(from start: BusStop, to end: BusStop) async -> RouteResult? {
        
        // 1. Direct Route Check
        for route in allRoutes {
            if route.stops.contains(start) && route.stops.contains(end) {
                return await createDirectResult(route: route, start: start, end: end)
            }
        }
        
        // 2. Interchange Check (1 Transfer)
        // Logic: Start -> TransferStop (via Route A) -> End (via Route B)
        for routeA in allRoutes where routeA.stops.contains(start) {
            for routeB in allRoutes where routeB.stops.contains(end) {
                // Find shared stops between the two routes
                let commonStops = Set(routeA.stops).intersection(Set(routeB.stops))
                
                if let transferStop = commonStops.first {
                    return await createTransferResult(routeA: routeA, routeB: routeB, start: start, transfer: transferStop, end: end)
                }
            }
        }
        return nil
    }
    
    // MARK: - LOGIC: Geometry Builders
    private func createDirectResult(route: BusRoute, start: BusStop, end: BusStop) async -> RouteResult {
        let roadCoordinates = await getRoadGeometry(from: start.coordinate, to: end.coordinate)
        
        let segment = RouteSegment(
            routeNumber: route.routeNumber,
            fromStop: start,
            toStop: end,
            pathCoordinates: roadCoordinates,
            colorHex: route.colorHex
        )
        return RouteResult(totalStops: 0, segments: [segment])
    }
    
    private func createTransferResult(routeA: BusRoute, routeB: BusRoute, start: BusStop, transfer: BusStop, end: BusStop) async -> RouteResult {
        // Calculate road paths for both legs of the journey simultaneously
        async let path1 = getRoadGeometry(from: start.coordinate, to: transfer.coordinate)
        async let path2 = getRoadGeometry(from: transfer.coordinate, to: end.coordinate)
        
        let (road1, road2) = await (path1, path2)
        
        let seg1 = RouteSegment(
            routeNumber: routeA.routeNumber,
            fromStop: start,
            toStop: transfer,
            pathCoordinates: road1,
            colorHex: routeA.colorHex
        )
        
        let seg2 = RouteSegment(
            routeNumber: routeB.routeNumber,
            fromStop: transfer,
            toStop: end,
            pathCoordinates: road2,
            colorHex: routeB.colorHex
        )
        
        return RouteResult(totalStops: 0, segments: [seg1, seg2])
    }
    
    // MARK: - LOGIC: Apple Maps API
    private func getRoadGeometry(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) async -> [CLLocationCoordinate2D] {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
        request.transportType = .automobile
        
        // Optimization: If points are super close (less than ~50 meters), skip API call
        if abs(start.latitude - end.latitude) < 0.0005 && abs(start.longitude - end.longitude) < 0.0005 {
            return [start, end]
        }

        do {
            let directions = MKDirections(request: request)
            let response = try await directions.calculate()
            if let route = response.routes.first {
                return route.polyline.coordinates
            }
        } catch {
            print("Direction Error: \(error.localizedDescription)")
        }
        
        // Fallback: If API fails or no internet, draw a straight line
        return [start, end]
    }
}

// Helper needed to convert Apple's data format to ours
extension MKPolyline {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        return coords
    }
}
