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

// 2. A Bus Route (Sequence of stops)
struct BusRoute: Identifiable {
    let id = UUID()
    let routeNumber: String
    let stops: [BusStop]
    let colorHex: String // "red" or "blue"
}

// 3. The Result of a Search (A path users will take)
struct RouteResult: Identifiable {
    let id = UUID()
    let totalStops: Int
    let segments: [RouteSegment] // Can be 1 segment (direct) or 2 (transfer)
}

struct RouteSegment: Identifiable {
    let id = UUID()
    let routeNumber: String
    let fromStop: BusStop
    let toStop: BusStop
    let pathCoordinates: [CLLocationCoordinate2D]
    let colorHex: String
}
