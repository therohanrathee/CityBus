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
        coordinate: CLLocationCoordinate2D(latitude: 28.4660, longitude: 77.0370) // TODO: UPDATE COORDINATE
    )
    
    let crpfCampChowk = BusStop(
        name: "CRPF Camp Chowk",
        coordinate: CLLocationCoordinate2D(latitude: 28.4680, longitude: 77.0390) // TODO: UPDATE COORDINATE
    )
    
    let sheetlaMataA = BusStop(
        name: "Sheetla Mata Mandir (A)",
        coordinate: CLLocationCoordinate2D(latitude: 28.4700, longitude: 77.0410) // TODO: UPDATE COORDINATE
    )
    
    let sheetlaMataB = BusStop(
        name: "Sheetla Mata Mandir (B)",
        coordinate: CLLocationCoordinate2D(latitude: 28.4705, longitude: 77.0415) // TODO: UPDATE COORDINATE
    )
    
    let sector5Ramlila = BusStop(
        name: "Sector - 5 Ramlila Ground",
        coordinate: CLLocationCoordinate2D(latitude: 28.4730, longitude: 77.0430) // TODO: UPDATE COORDINATE
    )
    
    let ashokViharPetrol = BusStop(
        name: "Ashok Vihar Phase 2 Petrol Pump",
        coordinate: CLLocationCoordinate2D(latitude: 28.4760, longitude: 77.0450) // TODO: UPDATE COORDINATE
    )
    
    let ashokViharExt = BusStop(
        name: "Ashok Vihar Phase III Extension",
        coordinate: CLLocationCoordinate2D(latitude: 28.4800, longitude: 77.0480) // TODO: UPDATE COORDINATE
    )
    
    let parkViewRes = BusStop(
        name: "Park View Residency",
        coordinate: CLLocationCoordinate2D(latitude: 28.4850, longitude: 77.0500) // TODO: UPDATE COORDINATE
    )
    
    let palamBlockC1 = BusStop(
        name: "Palam Vihar Block C1/Ashok Vihar Phase III",
        coordinate: CLLocationCoordinate2D(latitude: 28.4900, longitude: 77.0520) // TODO: UPDATE COORDINATE
    )
    
    let krishnaChowk = BusStop(
        name: "Krishna Chowk Palam Vihar",
        coordinate: CLLocationCoordinate2D(latitude: 28.4950, longitude: 77.0550) // TODO: UPDATE COORDINATE
    )
    
    let dharamColony = BusStop(
        name: "Dharam Colony",
        coordinate: CLLocationCoordinate2D(latitude: 28.5000, longitude: 77.0580) // TODO: UPDATE COORDINATE
    )
    
    let carterpuriVillage = BusStop(
        name: "Carterpuri Village",
        coordinate: CLLocationCoordinate2D(latitude: 28.5050, longitude: 77.0600) // TODO: UPDATE COORDINATE
    )
    
    let columbiaAsia = BusStop(
        name: "Columbia Asia Hospital",
        coordinate: CLLocationCoordinate2D(latitude: 28.5100, longitude: 77.0620) // TODO: UPDATE COORDINATE
    )
    
    let cosmosApt = BusStop(
        name: "Cosmos Executive Apartment",
        coordinate: CLLocationCoordinate2D(latitude: 28.5150, longitude: 77.0650) // TODO: UPDATE COORDINATE
    )
    
    let ramMandir = BusStop(
        name: "Ram Mandir Palam Vihar",
        coordinate: CLLocationCoordinate2D(latitude: 28.5200, longitude: 77.0700) // TODO: UPDATE COORDINATE
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
