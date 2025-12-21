import SwiftUI
import MapKit

struct ContentView: View {
    @State private var locationManager = LocationManager()
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    @State private var activeRoute: RouteResult?
    @State private var isSheetPresented = true
    
    var body: some View {
        ZStack {
            // MARK: - Map Layer
            if locationManager.isAuthorized {
                Map(position: $position) {
                    UserAnnotation()
                    
                    // Draw the calculated route if one exists
                    if let route = activeRoute {
                        ForEach(route.segments) { segment in
                            // 1. Draw the Line
                            MapPolyline(coordinates: segment.pathCoordinates)
                                .stroke(colorFor(segment.colorHex), lineWidth: 6)
                            
                            // 2. Mark the Stops
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
                    // Adds spacer so the "Apple Maps" logo isn't hidden by our sheet
                    Color.clear.frame(height: 80)
                }
                
            } else {
                // Permission Screen
                ContentUnavailableView(
                    "Bus Tracking",
                    systemImage: "bus.fill",
                    description: Text("Please enable location services to use the app.")
                )
                Button("Allow Location") {
                    locationManager.requestPermission()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        // MARK: - Bottom Sheet Logic
        .sheet(isPresented: $isSheetPresented) {
            SearchSheetView(selectedRoute: $activeRoute, mapPosition: $position)
                .presentationDetents([.fraction(0.20), .medium, .large])
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                .presentationCornerRadius(25)
                .interactiveDismissDisabled()
        }
        .onAppear {
            locationManager.requestPermission()
        }
    }
    
    // Helper to convert string to color
    func colorFor(_ hex: String) -> Color {
        return hex == "red" ? .red : .blue
    }
}

#Preview {
    ContentView()
}
