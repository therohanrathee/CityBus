import Foundation

class RouteManager {
    static let shared = RouteManager()
    
    // Access the stops
    private let stops = StopManager.shared
    
    // --- MASTER ROUTE INVENTORY ---
    
    var route222C: BusRoute {
        BusRoute(
            routeNumber: "222C",
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
            colorHex: "red"
        )
    }
    
    // --- Helper to get all routes ---
    var allRoutes: [BusRoute] {
        return [route222C]
    }
}
