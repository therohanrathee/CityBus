import SwiftUI
import MapKit

struct ContentView: View {
    @State private var locationManager = LocationManager()
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var activeRoute: RouteResult?
    @State private var isSheetPresented = true
    
    var body: some View {
        ZStack {
            // MARK: - 1. The Map Layer
            if locationManager.isAuthorized {
                Map(position: $position) {
                    UserAnnotation()
                    
                    if let route = activeRoute {
                        ForEach(route.segments) { segment in
                            MapPolyline(coordinates: segment.pathCoordinates)
                                .stroke(colorFor(segment.colorHex), lineWidth: 6)
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
                    Color.clear.frame(height: 100)
                }
                
            } else {
                ContentUnavailableView(
                    "Location Required",
                    systemImage: "location.slash.fill",
                    description: Text("Please enable location permissions.")
                )
                Button("Allow Location") {
                    locationManager.requestPermission()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        // MARK: - 2. The Bottom Sheet
        .sheet(isPresented: $isSheetPresented) {
            SearchSheetView(
                selectedRoute: $activeRoute,
                mapPosition: $position,
                userLocation: locationManager.location
            )
            // FIX: .height(80) creates the "Compact Pill" look
            .presentationDetents([.height(80), .medium, .large])
            .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            .presentationBackground(.clear) // Transparent wrapper
            .presentationDragIndicator(.visible) // System handle (small grey line)
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
