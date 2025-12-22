import Foundation
import CoreLocation

// 1. A Bus Stop
struct BusStop: Identifiable, Hashable, Equatable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    
    static func == (lhs: BusStop, rhs: BusStop) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// 2. A Bus Route
struct BusRoute: Identifiable {
    let id = UUID()
    let routeNumber: String // e.g. "222C UP"
    let stops: [BusStop]
    let colorHex: String
}

// 3. Search Result
struct RouteResult: Identifiable {
    let id = UUID()
    let totalStops: Int
    let segments: [RouteSegment]
}

struct RouteSegment: Identifiable {
    let id = UUID()
    let routeNumber: String
    let fromStop: BusStop
    let toStop: BusStop
    let pathCoordinates: [CLLocationCoordinate2D]
    let colorHex: String
}

// 4. NEW: The Static Bus Vehicle
struct Bus: Identifiable {
    let id = UUID()
    let routeNumber: String // Matches the route (e.g., "222C UP")
    let coordinate: CLLocationCoordinate2D
    let direction: String // "UP" or "DOWN" (Just for reference)
}
