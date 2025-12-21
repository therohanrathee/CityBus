import SwiftUI
import MapKit

struct SearchSheetView: View {
    @Binding var selectedRoute: RouteResult?
    @Binding var mapPosition: MapCameraPosition
    
    @State private var searchText = ""
    @State private var filteredStops: [BusStop] = []
    
    let calculator = RouteCalculator.shared
    
    var body: some View {
        VStack(spacing: 24) {
            // Search Bar
            TextField("Where to?", text: $searchText)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .onChange(of: searchText) { oldValue, newValue in
                    filterStops()
                }
            
            // List of Destinations
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
        .padding(.top)
        .onAppear {
            filteredStops = calculator.allStops
        }
    }
    
    func filterStops() {
        if searchText.isEmpty {
            filteredStops = calculator.allStops
        } else {
            filteredStops = calculator.allStops.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    func calculateRoute(to destination: BusStop) {
        guard let startStop = calculator.allStops.first(where: { $0.name.contains("Ram Mandir") }) else { return }
        
        // Don't route to yourself
        if startStop == destination { return }
        
        // Use 'Task' to run the async code
        Task {
            if let result = await calculator.findRoute(from: startStop, to: destination) {
                // Update UI on the main thread
                await MainActor.run {
                    self.selectedRoute = result
                    
                    if let firstPoint = result.segments.first?.fromStop.coordinate {
                        withAnimation {
                            self.mapPosition = .region(MKCoordinateRegion(
                                center: firstPoint,
                                span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
                            ))
                        }
                    }
                }
            }
        }
    }
}
