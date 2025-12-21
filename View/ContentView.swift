import SwiftUI
import MapKit

struct ContentView: View {
    @State private var locationManager = LocationManager()
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    // This holds the route we want to draw
    @State private var activeRoute: RouteResult?
    @State private var isSheetPresented = true
    
    var body: some View {
        ZStack {
            // MARK: - 1. The Map Layer
            if locationManager.isAuthorized {
                Map(position: $position) {
                    UserAnnotation()
                    
                    // Draw the route if one is selected
                    if let route = activeRoute {
                        ForEach(route.segments) { segment in
                            // Draw the road path
                            MapPolyline(coordinates: segment.pathCoordinates)
                                .stroke(colorFor(segment.colorHex), lineWidth: 6)
                            
                            // Draw the stops along the way
                            Marker(segment.fromStop.name, coordinate: segment.fromStop.coordinate)
                                .tint(colorFor(segment.colorHex))
                            
                            Marker(segment.toStop.name, coordinate: segment.toStop.coordinate)
                                .tint(colorFor(segment.colorHex))
                        }
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                }
                .safeAreaInset(edge: .bottom) {
                    // Spacer so Apple Maps logo isn't hidden by the sheet
                    Color.clear.frame(height: 80)
                }
                
            } else {
                // Permission Denied View
                ContentUnavailableView(
                    "Location Required",
                    systemImage: "location.slash.fill",
                    description: Text("Please enable location permissions to track buses.")
                )
                Button("Allow Location") {
                    locationManager.requestPermission()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        // MARK: - 2. The Bottom Sheet
        .sheet(isPresented: $isSheetPresented) {
            SearchSheetView(selectedRoute: $activeRoute, mapPosition: $position)
                .presentationDetents([.fraction(0.20), .medium, .large])
                .presentationBackgroundInteraction(.enabled(upThrough: .medium)) // Allows map interaction
                .presentationCornerRadius(25)
                .interactiveDismissDisabled()
        }
        .onAppear {
            locationManager.requestPermission()
        }
    }
    
    func colorFor(_ hex: String) -> Color {
        return hex == "red" ? .red : .blue
    }
}
