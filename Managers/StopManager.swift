import Foundation
import CoreLocation

class StopManager {
    static let shared = StopManager()
    
    // --- MASTER STOP INVENTORY ---
    
    let gurugramBusStand = BusStop(
        name: "Gurugram Bus Stand",
        coordinate: CLLocationCoordinate2D(latitude: 28.46524, longitude: 77.03174)
    )
    
    let sector12Chowk = BusStop(
        name: "Sector - 12 Chowk",
        coordinate: CLLocationCoordinate2D(latitude: 28.47069, longitude: 77.03405)
    )
    
    let rajeevNagarChowk = BusStop(
        name: "Rajeev Nagar chowk",
        coordinate: CLLocationCoordinate2D(latitude: 28.47608, longitude: 77.03479)
    )
    
    let crpfCampChowk = BusStop(
        name: "CRPF Camp Chowk",
        coordinate: CLLocationCoordinate2D(latitude: 28.47847, longitude: 77.03510)
    )
    
    let sheetlaMataA = BusStop(
        name: "Sheetla Mata Mandir (A)",
        coordinate: CLLocationCoordinate2D(latitude: 28.47897, longitude: 77.03174)
    )
    
    let sheetlaMataB = BusStop(
        name: "Sheetla Mata Mandir (B)",
        coordinate: CLLocationCoordinate2D(latitude: 28.47997, longitude: 77.02784)
    )
    
    let sector5Ramlila = BusStop(
        name: "Sector - 5 Ramlila Ground",
        coordinate: CLLocationCoordinate2D(latitude: 28.48279, longitude: 77.02190)
    )
    
    let ashokViharPetrol = BusStop(
        name: "Ashok Vihar Phase 2 Petrol Pump",
        coordinate: CLLocationCoordinate2D(latitude: 28.49046, longitude: 77.01967)
    )
    
    let ashokViharExt = BusStop(
        name: "Ashok Vihar Phase III Extension",
        coordinate: CLLocationCoordinate2D(latitude: 28.49437, longitude: 77.02036)
    )
    
    let parkViewRes = BusStop(
        name: "Park View Residency",
        coordinate: CLLocationCoordinate2D(latitude: 28.49754, longitude: 77.02277)
    )
    
    let palamBlockC1 = BusStop(
        name: "Palam Vihar Block C1/Ashok Vihar Phase III",
        coordinate: CLLocationCoordinate2D(latitude: 28.50018, longitude: 77.02629)
    )
    
    let krishnaChowk = BusStop(
        name: "Krishna Chowk Palam Vihar",
        coordinate: CLLocationCoordinate2D(latitude: 28.50205, longitude: 77.02888)
    )
    
    let dharamColony = BusStop(
        name: "Dharam Colony",
        coordinate: CLLocationCoordinate2D(latitude: 28.50354, longitude: 77.03549)
    )
    
    let carterpuriVillage = BusStop(
        name: "Carterpuri Village",
        coordinate: CLLocationCoordinate2D(latitude: 28.50728, longitude: 77.03933)
    )
    
    let columbiaAsia = BusStop(
        name: "Columbia Asia Hospital",
        coordinate: CLLocationCoordinate2D(latitude: 28.50935, longitude: 77.04104)
    )
    
    let cosmosApt = BusStop(
        name: "Cosmos Executive Apartment",
        coordinate: CLLocationCoordinate2D(latitude: 28.51393, longitude: 77.03598)
    )
    
    let ramMandir = BusStop(
        name: "Ram Mandir Palam Vihar",
        coordinate: CLLocationCoordinate2D(latitude: 28.51501, longitude: 77.03449)
    )
    
    // --- Helper to get all stops as a list ---
    var allStops: [BusStop] {
        return [
            gurugramBusStand, sector12Chowk, rajeevNagarChowk, crpfCampChowk,
            sheetlaMataA, sheetlaMataB, sector5Ramlila, ashokViharPetrol,
            ashokViharExt, parkViewRes, palamBlockC1, krishnaChowk,
            dharamColony, carterpuriVillage, columbiaAsia, cosmosApt, ramMandir
        ]
    }
}
