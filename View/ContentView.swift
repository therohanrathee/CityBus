import SwiftUI
import MapKit

struct ContentView: View {
    @State private var locationManager = LocationManager()
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var activeRoute: RouteResult?
    @State private var isSheetPresented = true
    
    var body: some View {
        ZStack {
            if locationManager.isAuthorized {
                Map(position: $position) {
                    UserAnnotation()
                    
                    if let route = activeRoute {
                        
                        // A. DRAW ROUTE SEGMENTS
                        ForEach(route.segments) { segment in
                            MapPolyline(coordinates: segment.pathCoordinates)
                                .stroke(
                                    colorForStatus(segment.status),
                                    style: StrokeStyle(
                                        lineWidth: 7, // Thicker for rounder look
                                        lineCap: .round, // <--- CLOSES THE GAP
                                        lineJoin: .round // <--- SMOOTHS CORNERS
                                    )
                                )
                            
                            // Show markers for critical points
                            if segment.status == .journey || segment.status == .approaching {
                                Marker(segment.fromStop.name, coordinate: segment.fromStop.coordinate)
                                    .tint(colorForStatus(segment.status))
                                Marker(segment.toStop.name, coordinate: segment.toStop.coordinate)
                                    .tint(colorForStatus(segment.status))
                            }
                        }
                        
                        // B. DRAW STATIC BUSES
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
                ContentUnavailableView("Location Required", systemImage: "location.slash.fill", description: Text("Enable location."))
                Button("Allow Location") { locationManager.requestPermission() }.buttonStyle(.borderedProminent)
            }
        }
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
    
    // MARK: - Color Logic
    func colorForStatus(_ status: SegmentStatus) -> Color {
        switch status {
        case .passed:
            return .gray // Solid Grey (Visible)
        case .approaching:
            return .orange
        case .journey:
            return .blue
        case .remaining:
            return .gray // Solid Grey
        }
    }
    
    func colorForRoute(_ number: String) -> Color {
        return number.contains("DOWN") ? .red : .blue
    }
}
