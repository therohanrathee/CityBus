import Foundation

class RouteManager {
    static let shared = RouteManager()
    
    private let stops = StopManager.shared
    
    // --- 1. UP ROUTE (Gurugram -> Palam Vihar) ---
    var route222C_UP: BusRoute {
        BusRoute(
            routeNumber: "222C UP",
            stops: [
                stops.gurugramBusStand,
                stops.sector12Chowk,
                stops.rajeevNagarChowk,
                stops.crpfCampChowk,
                stops.sheetlaMataA,
                stops.sheetlaMataB,
                stops.sector5Ramlila,
                stops.ashokViharPetrol,
                stops.ashokViharExt,
                stops.parkViewRes,
                stops.palamBlockC1,
                stops.krishnaChowk,
                stops.dharamColony,
                stops.carterpuriVillage,
                stops.columbiaAsia,
                stops.cosmosApt,
                stops.ramMandir
            ],
            colorHex: "blue"
        )
    }
    
    // --- 2. DOWN ROUTE (Palam Vihar -> Gurugram) ---
    // We simply reverse the stops of the UP route
    var route222C_DOWN: BusRoute {
        BusRoute(
            routeNumber: "222C DOWN",
            stops: route222C_UP.stops.reversed(),
            colorHex: "red" // Different color to distinguish
        )
    }
    
    // --- Helper to get all routes ---
    var allRoutes: [BusRoute] {
        return [route222C_UP, route222C_DOWN]
    }
}
