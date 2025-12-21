# CityBus 🚌

CityBus is a native iOS application designed to simplify bus navigation in **Gurugram, India**. Built with **SwiftUI** and **MapKit**, it helps users find the best bus routes, visualize them on a map, and navigate from their current location to their destination.

## 🌟 Features

- **Route Finder**: intelligently calculates the best route between your nearest bus stop and your destination.
- **Interactive Map**: Visualizes the bus route on an Apple Map using `MapPolyline`, showing the actual path along roads.
- **Smart Directions**: Uses `MKDirections` to generate walking paths between stops, ensuring the route line follows road geometry instead of straight lines.
- **Stop Search**: Search for specific bus stops by name.
- **Location Integration**: Automatically detects your current location to find the nearest starting point.
- **Direct & Transfer Support**: The logic supports both direct bus routes and routes requiring a transfer (currently showcased with Route 222C).
- **Favorites**: Save frequently visited locations like Home, Work, and Gym.

## 📱 Screenshots

<!-- Add screenshots here -->
*(Screenshots placeholder)*

## 🛠 Tech Stack

- **Language**: Swift 5+
- **UI Framework**: SwiftUI
- **Map Framework**: MapKit (`Map`, `MapPolyline`, `Marker`)
- **Location Services**: CoreLocation
- **Data Model**: SwiftData (Architecture ready)
- **Architecture**: MVVM (Model-View-ViewModel)

## 📂 Project Structure

- **App/**: Contains the main entry point `CityBusApp.swift`.
- **View/**: SwiftUI views including the main map interface (`ContentView`) and the search sheet (`SearchSheetView`).
- **Managers/**: Core business logic:
  - `LocationManager.swift`: Handles user permission and location updates.
  - `RouteCalculator.swift`: Logic for finding nearest stops and calculating paths (direct or with transfers).
  - `StopManager.swift`: Registry of bus stops (currently tailored for Gurugram).
  - `RouteManager.swift`: Definitions of bus routes (e.g., Route 222C).
- **Models/**: Data structures for `BusStop`, `BusRoute`, and `RouteResult`.

## 🚀 Getting Started

### Requirements
- iOS 17.0+
- Xcode 15.0+

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/CityBus.git
   ```
2. Open `CityBus.xcodeproj` in Xcode.
3. Select the simulator or your physical device.
4. Build and Run (`Cmd + R`).

> **Note**: For the route calculation and map features to work on the simulator, ensure you simulate a location in **Gurugram** (e.g., near *Gurugram Bus Stand* or *Palam Vihar*). The app relies on `StopManager.swift` which contains hardcoded coordinates for this region.

## 🗺 Data Coverage

Currently, the app includes data for **Route 222C** in Gurugram, covering stops such as:
- Gurugram Bus Stand
- Sector 12 Chowk
- Rajeev Nagar Chowk
- Sheetla Mata Mandir
- Palam Vihar
- And more...

## 🔮 Future Improvements

- **Real-time Data**: Integrate with a backend or API to get live bus locations.
- **Expanded Coverage**: Add more routes and stops dynamically.
- **Fare Estimation**: Calculate ticket prices based on distance.
- **Offline Mode**: Cache routes for offline access.

## ✍️ Author

Created by **Rohan Rathee**.

---

*This project is a demonstration of using modern SwiftUI and MapKit features for transit navigation.*
