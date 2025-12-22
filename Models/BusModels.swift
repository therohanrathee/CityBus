import Foundation
import CoreLocation

// 1. Segment Status Enum (For Color Coding)
enum SegmentStatus {
    case passed      // Bus has already passed this (Grey)
    case approaching // Bus is coming to you (Orange)
    case journey     // You are on the bus (Blue)
    case remaining   // After your destination (Grey/Light Blue)
}

// 2. Bus Stop
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

// 3. Bus Route
struct BusRoute: Identifiable {
    let id = UUID()
    let routeNumber: String
    let stops: [BusStop]
    let colorHex: String
}

// 4. Route Result
struct RouteResult: Identifiable {
    let id = UUID()
    let totalStops: Int
    let segments: [RouteSegment]
}

// 5. Route Segment (Updated with Status)
struct RouteSegment: Identifiable {
    let id = UUID()
    let routeNumber: String
    let fromStop: BusStop
    let toStop: BusStop
    let pathCoordinates: [CLLocationCoordinate2D]
    let colorHex: String
    let status: SegmentStatus // <--- NEW FIELD
}

// 6. Bus Vehicle
struct Bus: Identifiable {
    let id = UUID()
    let routeNumber: String
    let coordinate: CLLocationCoordinate2D
    let direction: String
}
