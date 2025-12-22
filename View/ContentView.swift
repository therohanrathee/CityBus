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
                        
                        // A. Draw the Route Line
                        ForEach(route.segments) { segment in
                            MapPolyline(coordinates: segment.pathCoordinates)
                                .stroke(colorFor(segment.colorHex), lineWidth: 6)
                            
                            // Draw Stops
                            Marker(segment.fromStop.name, coordinate: segment.fromStop.coordinate)
                                .tint(colorFor(segment.colorHex))
                            Marker(segment.toStop.name, coordinate: segment.toStop.coordinate)
                                .tint(colorFor(segment.colorHex))
                        }
                        
                        // B. Draw Static Buses
                        // Filter to show only buses matching this route number (e.g. "222C UP")
                        ForEach(BusManager.shared.staticBuses.filter { $0.routeNumber == route.segments.first?.routeNumber }) { bus in
                            Annotation(bus.routeNumber, coordinate: bus.coordinate) {
                                ZStack {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 30, height: 30)
                                        .shadow(radius: 2)
                                    
                                    Image(systemName: "bus.fill")
                                        .font(.system(size: 14))
                                        .foregroundStyle(colorForRoute(bus.routeNumber))
                                }
                            }
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
            .presentationDetents([.height(80), .medium, .large])
            .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            .presentationBackground(.clear)
            .presentationDragIndicator(.visible)
            .interactiveDismissDisabled()
        }
        .onAppear {
            locationManager.requestPermission()
        }
    }
    
    // Helpers for Colors
    func colorFor(_ hex: String) -> Color {
        return hex == "red" ? .red : .blue
    }
    
    func colorForRoute(_ number: String) -> Color {
        return number.contains("DOWN") ? .red : .blue
    }
}
