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
                        
                        // A. ROUTE SEGMENTS
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
                            
                            // B. PINS
                            if shouldShowPin(for: segment.status) {
                                Marker(segment.fromStop.name, coordinate: segment.fromStop.coordinate)
                                    .tint(colorForStatus(segment.status))
                                
                                if segment.status == .journey {
                                    Marker(segment.toStop.name, coordinate: segment.toStop.coordinate)
                                        .tint(colorForStatus(segment.status))
                                }
                            }
                        }
                        
                        // C. STATIC BUSES
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
                
                // MARK: - LIQUID GLASS PIN MODE BUTTON
                .overlay(alignment: .topTrailing) {
                    if activeRoute != nil {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                pinMode = pinMode.next()
                            }
                        } label: {
                            Image(systemName: pinMode.iconName)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(.blue)
                                .liquidGlassCircle()
                        }
                        .padding(.top, 123)
                        .padding(.trailing, 16)
                        .transition(.scale.combined(with: .opacity))
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
        case .passed: return .gray
        case .approaching: return .orange
        case .journey: return .blue
        case .remaining: return .gray
        }
    }
    
    func colorForRoute(_ number: String) -> Color {
        number.contains("DOWN") ? .red : .blue
    }
}

#Preview {
    ContentView()
}

/////////////////////////////////////////////////////////////
// MARK: - REAL LIQUID GLASS IMPLEMENTATION
/////////////////////////////////////////////////////////////

struct GlassBlur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemUltraThinMaterialDark
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

struct LiquidGlassCircleButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 44, height: 44)
            .background {
                ZStack {
                    // TRUE glass blur (no white tint)
                    GlassBlur(style: .systemUltraThinMaterialDark)
                        .clipShape(Circle())
                    
                    // Subtle edge highlight
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.4),
                                    .white.opacity(0.1),
                                    .clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                }
            }
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 6)
    }
}

extension View {
    func liquidGlassCircle() -> some View {
        modifier(LiquidGlassCircleButton())
    }
}
