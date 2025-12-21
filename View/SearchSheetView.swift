import SwiftUI
import MapKit

// MARK: - Models

struct Favorite {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
}

// MARK: - Main View

struct SearchSheetView: View {
    @Binding var selectedRoute: RouteResult?
    @Binding var mapPosition: MapCameraPosition

    var userLocation: CLLocation?

    @State private var searchText = ""
    @State private var filteredStops: [BusStop] = []
    @State private var isCalculating = false
    @FocusState private var isSearchFocused: Bool

    let calculator = RouteCalculator.shared

    // MARK: - Favorites Data
    let favorites: [Favorite] = [
        Favorite(icon: "briefcase.fill", color: .blue, title: "Work", subtitle: "Add"),
        Favorite(icon: "house.fill", color: .blue, title: "Home", subtitle: "Add"),
        Favorite(icon: "mappin.circle.fill", color: .pink, title: "Gym", subtitle: "2 km")
        // Add more if needed — capped at 4
    ]

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Search Header
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.secondary)

                TextField("Where To?", text: $searchText)
                    .font(.system(size: 20))
                    .textFieldStyle(.plain)
                    .focused($isSearchFocused)
                    .onChange(of: searchText) { _, _ in
                        filterStops()
                    }

                if isSearchFocused || !searchText.isEmpty {
                    Button("Cancel") {
                        isSearchFocused = false
                        searchText = ""
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil, from: nil, for: nil
                        )
                    }
                    .font(.system(size: 17))
                    .foregroundStyle(.blue)
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 36, height: 36)
                        .foregroundStyle(.gray)
                }
            }
            .padding(.top, 24)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            // MARK: - Content
            if isCalculating {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Calculating route...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxHeight: .infinity)
                .padding(.top, 40)

            } else if searchText.isEmpty && !isSearchFocused {

                // MARK: - Favorites & Recents
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        // Favorites
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Favorites")
                                    .font(.headline)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            let maxFavorites = 4
                            let showAdd = favorites.count < maxFavorites

                            HStack {
                                Spacer()

                                ForEach(favorites.prefix(maxFavorites), id: \.title) { fav in
                                    FavoriteItem(
                                        icon: fav.icon,
                                        color: fav.color,
                                        title: fav.title,
                                        subtitle: fav.subtitle
                                    )
                                    .frame(maxWidth: .infinity)
                                }

                                if showAdd {
                                    FavoriteItem(
                                        icon: "plus",
                                        color: .gray,
                                        title: "Add",
                                        subtitle: ""
                                    )
                                    .frame(maxWidth: .infinity)
                                }

                                Spacer()
                            }
                        }

                        // Recents
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recents")
                                .font(.headline)
                                .foregroundStyle(.secondary)

                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundStyle(.gray)
                                Text("No recent searches")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 20)
                }

            } else {

                // MARK: - Search Results
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredStops) { stop in
                            VStack(spacing: 0) {
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 36, height: 36)

                                        Image(systemName: "bus.fill")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundStyle(.white)
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(stop.name)
                                            .font(.system(size: 17, weight: .medium))
                                            .lineLimit(1)

                                        Text("Bus Stop")
                                            .font(.system(size: 13))
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    calculateRoute(to: stop)
                                    isSearchFocused = false
                                }

                                Divider()
                                    .padding(.leading, 72)
                            }
                        }
                    }
                    .padding(.top, 10)
                }
                .scrollIndicators(.hidden)
            }
        }
        // MARK: - IMPORTANT: No Background (Transparent Sheet)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Logic

    func filterStops() {
        filteredStops = searchText.isEmpty
        ? calculator.allStops
        : calculator.allStops.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    func calculateRoute(to destination: BusStop) {
        guard let currentLoc = userLocation,
              let nearestStop = calculator.findNearestStop(to: currentLoc),
              nearestStop != destination else { return }

        isCalculating = true

        Task {
            if let result = await calculator.findRoute(from: nearestStop, to: destination) {
                await MainActor.run {
                    selectedRoute = result
                    isCalculating = false

                    if let firstPoint = result.segments.first?.fromStop.coordinate {
                        withAnimation {
                            mapPosition = .region(
                                MKCoordinateRegion(
                                    center: firstPoint,
                                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                )
                            )
                        }
                    }
                }
            } else {
                await MainActor.run { isCalculating = false }
            }
        }
    }
}

// MARK: - Favorite Item View

struct FavoriteItem: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 60, height: 60)

                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.white)
            }

            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
