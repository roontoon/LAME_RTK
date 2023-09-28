// Import SwiftUI for UI components
import SwiftUI
import CoreLocation  // Import CoreLocation for CLLocationCoordinate2D

// ContentView struct conforming to the View protocol
struct ContentView: View {
    
    // Using Environment to fetch the managedObjectContext
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    // Fetch the default latitude and longitude from AppStorage
    @AppStorage("defaultLongitude") var defaultLongitude: Double = 0.0
    @AppStorage("defaultLatitude") var defaultLatitude: Double = 0.0
    
    // The body property for the ContentView
    var body: some View {
        
        // Using TabView to create a tab-based layout
        TabView {
            
            // Tab 1: GPSDataView
            GPSDataView()
                .tabItem {
                    Image(systemName: "1.circle.fill")  // Tab icon
                    Text("GPS Data")  // Tab title
                }
            
            // Tab 2: JoyStickView
            JoyStickView()
                .tabItem {
                    Image(systemName: "2.circle.fill")  // Tab icon
                    Text("JoyStick View")  // Tab title
                }
            
            // Tab 3: MapView
            // Initialize MapView with default location
           /* CustomMapView(defaultLatitude:defaultLatitude,defaultLongitude:defaultLongitude, gpsDataPoints: [CLLocationCoordinate2D(latitude: defaultLatitude, longitude: defaultLongitude)])  */
            LAMEMapView()
                        //.ignoresSafeArea()
                .tabItem {
                    Image(systemName: "3.circle.fill")  // Tab icon
                    Text("MapView")  // Tab title
                }
            
            // Tab 4: PreferencesView
            PreferencesView()
                .tabItem {
                    Image(systemName: "4.circle.fill")  // Tab icon
                    Text("PreferencesView")  // Tab title
                }
            
            // Tab 5: Placeholder
            Text("Tab 5 Content")
                .tabItem {
                    Image(systemName: "5.circle.fill")  // Tab icon
                    Text("Tab 5")  // Tab title
                }
        }
    }
}

// Preview for ContentView
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()  // Previewing the ContentView
    }
}
