import SwiftUI
import MapKit

// MARK: - Pin Display Modes
enum PinDisplayMode {
    case all
    case upcoming
    case hidden
    
    var iconName: String {
        switch self {
        case .all: return "mappin.and.ellipse"
        case .upcoming: return "mappin"
        case .hidden: return "mappin.slash"
        }
    }
    
    func next() -> PinDisplayMode {
        switch self {
        case .all: return .upcoming
        case .upcoming: return .hidden
        case .hidden: return .all
        }
    }
}

struct ContentView: View {
    @State private var locationManager = LocationManager()
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var activeRoute: RouteResult?
    @State private var isSheetPresented = true
    @State private var pinMode: PinDisplayMode = .all
    
    var body: some View {
        ZStack {
            if locationManager.isAuthorized {
                Map(position: $position) {
                    UserAnnotation()
                    
                    if let route = activeRoute {
                        
                        // MARK: - ROUTE SEGMENTS
                        ForEach(route.segments) { segment in
                            MapPolyline(coordinates: segment.pathCoordinates)
                                .stroke(
                                    colorForStatus(segment.status),
                                    style: StrokeStyle(
                                        lineWidth: 7,
                                        lineCap: .round,
                                        lineJoin: .round
                                    )
                                )
                            
                            // MARK: - PINS
                            if shouldShowPin(for: segment.status) {
                                Marker(segment.fromStop.name, coordinate: segment.fromStop.coordinate)
                                    .tint(colorForStatus(segment.status))
                                
                                if segment.status == .journey {
                                    Marker(segment.toStop.name, coordinate: segment.toStop.coordinate)
                                        .tint(colorForStatus(segment.status))
                                }
                            }
                        }
                        
                        // MARK: - STATIC BUSES
                        ForEach(
                            BusManager.shared.staticBuses
                                .filter { $0.routeNumber == route.segments.first?.routeNumber }
                        ) { bus in
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
                    MapScaleView()
                }
                
                // MARK: - SIMPLE PIN MODE BUTTON
                .overlay(alignment: .topTrailing) {
                    if activeRoute != nil {
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                pinMode = pinMode.next()
                            }
                        } label: {
                            Image(systemName: pinMode.iconName)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(.primary)
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                        .padding(.top, 123)
                        .padding(.trailing, 16)
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 100)
                }
                
            } else {
                VStack(spacing: 16) {
                    ContentUnavailableView(
                        "Location Required",
                        systemImage: "location.slash.fill",
                        description: Text("Enable location to view routes.")
                    )
                    
                    Button("Allow Location") {
                        locationManager.requestPermission()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        // MARK: - SEARCH SHEET
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
    
    // MARK: - Helpers
    
    func shouldShowPin(for status: SegmentStatus) -> Bool {
        switch pinMode {
        case .all:
            return true
        case .upcoming:
            return status == .approaching || status == .journey
        case .hidden:
            return false
        }
    }
    
    func colorForStatus(_ status: SegmentStatus) -> Color {
        switch status {
        case .passed:
            return .gray
        case .approaching:
            return .orange
        case .journey:
            return .blue
        case .remaining:
            return .gray
        }
    }
    
    func colorForRoute(_ number: String) -> Color {
        number.contains("DOWN") ? .red : .blue
    }
}

#Preview {
    ContentView()
}
