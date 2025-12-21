import SwiftUI
import MapKit

struct SearchSheetView: View {
    @Binding var selectedRoute: RouteResult?
    @Binding var mapPosition: MapCameraPosition
    
    @State private var searchText = ""
    @State private var filteredStops: [BusStop] = []
    @State private var isCalculating = false // Loading state
    
    // Access the logic we updated
    let calculator = RouteCalculator.shared
    
    var body: some View {
        VStack(spacing: 24) {
            // MARK: - Search Bar
            TextField("Search for a stop (e.g., Cyber Hub)", text: $searchText)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .onChange(of: searchText) { oldValue, newValue in
                    filterStops()
                }
            
            // MARK: - Loading Indicator or List
            if isCalculating {
                VStack {
                    ProgressView()
                    Text("Finding best route...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxHeight: .infinity)
            } else {
                List(filteredStops) { stop in
                    Button {
                        calculateRoute(to: stop)
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "bus.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.blue)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading) {
                                Text(stop.name)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text("Bus Stop")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
        }
        .padding(.top)
        .onAppear {
            filteredStops = calculator.allStops
        }
    }
    
    // Filter logic
    func filterStops() {
        if searchText.isEmpty {
            filteredStops = calculator.allStops
        } else {
            filteredStops = calculator.allStops.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - The Async Route Call
    func calculateRoute(to destination: BusStop) {
        // DEMO START POINT: Using 'Ram Mandir' as the starting location.
        // In the final app, you will replace this with the user's real GPS location.
        guard let startStop = calculator.allStops.first(where: { $0.name.contains("Ram Mandir") }) else { return }
        
        if startStop == destination { return }
        
        isCalculating = true // Start loading
        
        // This 'Task' block is required for the new Async code
        Task {
            if let result = await calculator.findRoute(from: startStop, to: destination) {
                
                // Update UI on main thread
                await MainActor.run {
                    self.selectedRoute = result
                    self.isCalculating = false // Stop loading
                    
                    // Zoom map to the start of the route
                    if let firstPoint = result.segments.first?.fromStop.coordinate {
                        withAnimation {
                            self.mapPosition = .region(MKCoordinateRegion(
                                center: firstPoint,
                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                            ))
                        }
                    }
                }
            } else {
                await MainActor.run {
                    self.isCalculating = false
                }
            }
        }
    }
}
