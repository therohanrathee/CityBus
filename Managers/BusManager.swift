import Foundation
import CoreLocation

class BusManager {
    static let shared = BusManager()
    
    // Access stops to place buses exactly at the stop location
    private let stops = StopManager.shared
    
    var staticBuses: [Bus] {
        return [
            // --- BUSES GOING UP (Gurugram -> Ram Mandir) ---
            
            // Bus 1: At Gurugram Bus Stand
            Bus(
                routeNumber: "222C UP",
                coordinate: stops.gurugramBusStand.coordinate,
                direction: "UP"
            ),
            
            // Bus 2: At Ashok Vihar Phase III Extension
            Bus(
                routeNumber: "222C UP",
                coordinate: stops.ashokViharExt.coordinate,
                direction: "UP"
            ),
            
            // --- BUSES GOING DOWN (Ram Mandir -> Gurugram) ---
            
            // Bus 3: At Krishna Chowk
            Bus(
                routeNumber: "222C DOWN",
                coordinate: stops.krishnaChowk.coordinate,
                direction: "DOWN"
            ),
            
            // Bus 4: At Sector 5 Ramlila Ground
            Bus(
                routeNumber: "222C DOWN",
                coordinate: stops.sector5Ramlila.coordinate,
                direction: "DOWN"
            )
        ]
    }
}
