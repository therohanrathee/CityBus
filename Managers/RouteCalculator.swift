import Foundation
import CoreLocation
import MapKit

class RouteCalculator {
    static let shared = RouteCalculator()
    
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
    
    // MARK: - LOGIC: Full Route Status
    func findRoute(from start: BusStop, to end: BusStop) async -> RouteResult? {
        for route in allRoutes {
            if let startIndex = route.stops.firstIndex(of: start),
               let endIndex = route.stops.firstIndex(of: end),
               startIndex < endIndex {
                
                return await createFullRouteResult(route: route, userStart: startIndex, userEnd: endIndex)
            }
        }
        return nil
    }

    // MARK: - BUILDER
    private func createFullRouteResult(route: BusRoute, userStart: Int, userEnd: Int) async -> RouteResult {
        
        var fullSegments: [RouteSegment] = []
        
        // 1. Find the correct bus (Closest one BEHIND the user)
        let busIndex = findBusIndex(on: route, userStartIndex: userStart)
        
        for i in 0..<(route.stops.count - 1) {
            let segmentStart = route.stops[i]
            let segmentEnd = route.stops[i+1]
            
            // 2. Determine Status
            var status: SegmentStatus = .remaining
            
            if i < busIndex {
                status = .passed // Grey
            } else if i >= busIndex && i < userStart {
                status = .approaching // Orange (Bus -> You)
            } else if i >= userStart && i < userEnd {
                status = .journey // Blue (You -> Destination)
            }
            
            let coords = await getRoadGeometry(from: segmentStart.coordinate, to: segmentEnd.coordinate)
            
            let segment = RouteSegment(
                routeNumber: route.routeNumber,
                fromStop: segmentStart,
                toStop: segmentEnd,
                pathCoordinates: coords,
                colorHex: route.colorHex,
                status: status
            )
            fullSegments.append(segment)
        }
        
        return RouteResult(totalStops: (userEnd - userStart), segments: fullSegments)
    }
    
    // MARK: - UPDATED LOGIC: Find Closest Bus
    private func findBusIndex(on route: BusRoute, userStartIndex: Int) -> Int {
        let busesOnRoute = BusManager.shared.staticBuses.filter { $0.routeNumber == route.routeNumber }
        
        // 1. Find all potential matches (Buses exactly at a stop)
        var validBusIndices: [Int] = []
        
        for bus in busesOnRoute {
            if let index = route.stops.firstIndex(where: {
                abs($0.coordinate.latitude - bus.coordinate.latitude) < 0.0001 &&
                abs($0.coordinate.longitude - bus.coordinate.longitude) < 0.0001
            }) {
                // Only consider buses BEHIND the user (or at the user's stop)
                if index <= userStartIndex {
                    validBusIndices.append(index)
                }
            }
        }
        
        // 2. Logic Fix: Pick the HIGHEST index (Closest bus to the user)
        // Previous logic picked the first one (0), which was wrong.
        return validBusIndices.max() ?? 0
    }
    
    // MARK: - API CALL
    private func getRoadGeometry(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) async -> [CLLocationCoordinate2D] {
        let request = MKDirections.Request()
        request.source = MKMapItem(location: CLLocation(latitude: start.latitude, longitude: start.longitude), address: nil)
        request.destination = MKMapItem(location: CLLocation(latitude: end.latitude, longitude: end.longitude), address: nil)
        request.transportType = .walking
        
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

extension MKPolyline {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        return coords
    }
}
