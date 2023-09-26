// Import SwiftUI for UI components and MapboxMaps for the map functionality
/*
 import SwiftUI
 import MapboxMaps
 
 // Define the CustomMapView struct that conforms to UIViewRepresentable
 struct CustomMapView: UIViewRepresentable {
 
 // Use AppStorage to store and retrieve default latitude and longitude
 @AppStorage("defaultLatitude") var defaultLatitude: Double = 0.0
 @AppStorage("defaultLongitude") var defaultLongitude: Double = 0.0

 // The updateUIView function updates the MapView when there are changes
 func updateUIView(_ uiView: MapView, context: Context) {
 print("3. Updating UIView")  // Debugging statement 3
 // Create camera options to set the center and zoom level of the map
 let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: defaultLatitude, longitude: defaultLongitude), zoom: 14.0)
 print("6. Setting Camera Options")  // Debugging statement 6
 // Ease the camera to the new position
 uiView.mapboxMap.setCamera(to: cameraOptions) {
 print("7. Camera Animation Completed")  // Debugging statement 7
 }
 }
 }
 
 */
