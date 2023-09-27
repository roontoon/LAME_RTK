// Import UIKit for building user interface, Mapbox for map functionality, and CoreData for database functionality.
import SwiftUI
import MapboxMaps
import CoreData

struct LAMEMapView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> MapViewController {
           return MapViewController()
       }
      
    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
    }
}

class MapViewController: UIViewController {
   // Declare a variable to hold the MapView from Mapbox.
   internal var mapView: MapView!
   
    // Fetch the default latitude and longitude from AppStorage
    @AppStorage("defaultLongitude") var defaultLongitude: Double = 0.0
    @AppStorage("defaultLatitude") var defaultLatitude: Double = 0.0

   // Declare a variable to hold the managed object context from Core Data.
   let managedObjectContext = PersistenceController.shared.container.viewContext
   
   override public func viewDidLoad() {
       super.viewDidLoad()
       
       // Initialize the camera options for Mapbox.
       //let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 28.069767, longitude: -82.484428), zoom: 19, bearing: 0, pitch: 0)

       let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: self.defaultLatitude, longitude: self.defaultLongitude), zoom: 19, bearing: 0, pitch: 0)
       
       // Initialize the resource options for Mapbox.
       let myResourceOptions = ResourceOptions(accessToken: "sk.eyJ1Ijoicm9vbnRvb24iLCJhIjoiY2xtamZ1b3UzMDJ4MjJrbDgxMm0ya3prMiJ9.VtLaE_XUfS9QSXa2QREpdQ")

       // Initialize the map with the given options.
       let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions, cameraOptions: cameraOptions)
       
       mapView = MapView(frame: view.bounds, mapInitOptions: myMapInitOptions)
       
       // Set the autoresizing mask for the MapView.
       mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
       
       // Add the MapView to the view hierarchy.
       self.view.addSubview(mapView)
       
       // Fetch and print GPS data points from Core Data.
       fetchAndPrintGPSData()
   }
   
   // Function to fetch GPS data points from Core Data and print them to the console.
   func fetchAndPrintGPSData() {
       // Create a fetch request for the GPSDataPoint entity.
       let fetchRequest: NSFetchRequest<GPSDataPoint> = GPSDataPoint.fetchRequest()
       
       do {
           // Execute the fetch request.
           let fetchedResults = try managedObjectContext.fetch(fetchRequest)
           
           // Loop through the fetched results and print each one.
           for dataPoint in fetchedResults {
               print("Latitude: \(dataPoint.latitude), Longitude: \(dataPoint.longitude)")
           }
       } catch {
           // Handle errors here.
           print("Failed to fetch GPS data points: \(error)")
       }
   }
}
