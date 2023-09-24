import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Tab 1: Linking to GPSDataView
            GPSDataView()
                .tabItem {
                    Image(systemName: "1.circle.fill")
                    Text("GPS Data")
                }
            
            // Tab 2: Link to JoyStickView
            JoyStickView()
                .tabItem {
                    Image(systemName: "2.circle.fill")
                    Text("JoyStick View")
                }
            
            // Tab 3: Link to DataMapView
            MapView()
                .tabItem {
                    Image(systemName: "3.circle.fill")
                    Text("MapView")
                }
            
            // Tab 4: Placeholder
            PreferencesView()
                .tabItem {
                    Image(systemName: "4.circle.fill")
                    Text("PreferencesView")
                }
            
            // Tab 5: Placeholder
            Text("Tab 5 Content")
                .tabItem {
                    Image(systemName: "5.circle.fill")
                    Text("Tab 5")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
