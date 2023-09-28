// Import the necessary modules for UI, Mapbox, and Core Data
import SwiftUI
import MapboxMaps
import CoreData

// Define a SwiftUI view that represents the MapViewController
struct LAMEMapView: UIViewControllerRepresentable {
    
    // Create and return a new MapViewController when the view is made
    func makeUIViewController(context: Context) -> MapViewController {
        return MapViewController()
    }
    
    // Update the MapViewController when there are changes
    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
    }
}

// Define the MapViewController class
class MapViewController: UIViewController {
    // Declare a MapView variable to hold the Mapbox map
    internal var mapView: MapView!
    
    // Fetch the default latitude and longitude from AppStorage
    @AppStorage("defaultLongitude") var defaultLongitude: Double = 0.0
    @AppStorage("defaultLatitude") var defaultLatitude: Double = 0.0
    
    // Declare a variable to hold the Core Data managed object context
    let managedObjectContext = PersistenceController.shared.container.viewContext
    
    // Function that runs when the view loads
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize Mapbox resource options
        let myResourceOptions = ResourceOptions(accessToken: "YourAccessTokenHere")
        
        // Initialize camera options for Mapbox
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: defaultLatitude, longitude: defaultLongitude), zoom: 19)
        
        // Initialize Mapbox map with resource and camera options
        let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions, cameraOptions: cameraOptions, styleURI: .streets)
        
        // Create a new MapView with the initialization options
        mapView = MapView(frame: view.bounds, mapInitOptions: myMapInitOptions)
        
        // Set the autoresizing mask for the MapView
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Add the MapView to the view hierarchy
        self.view.addSubview(mapView)
        
        // Fetch and annotate GPS data points from Core Data
        fetchAndAnnotateGPSData()
    }
    
    // Function to fetch and annotate GPS data points from Core Data
    func fetchAndAnnotateGPSData() {
        // Create a fetch request for the GPSDataPoint entity
        let fetchRequest: NSFetchRequest<GPSDataPoint> = GPSDataPoint.fetchRequest()
        
        do {
            // Execute the fetch request and store the results
            let fetchedResults = try managedObjectContext.fetch(fetchRequest)
            
            // Initialize an empty array to hold PointAnnotations
            var pointAnnotations: [PointAnnotation] = []
            
            // Initialize arrays to hold coordinates for each entry type
            var perimeterCoordinates: [CLLocationCoordinate2D] = []
            var excludedCoordinates: [CLLocationCoordinate2D] = []
            var chargingCoordinates: [CLLocationCoordinate2D] = []
            
            // Loop through the fetched Core Data records
            for dataPoint in fetchedResults {
                // Create a PointAnnotation for each data point
                let coordinate = CLLocationCoordinate2DMake(dataPoint.latitude, dataPoint.longitude)
                var pointAnnotation = PointAnnotation(coordinate: coordinate)
                
                // Assign an image to the annotation based on the entryType
                switch dataPoint.entryType {
                case "Perimeter":
                    pointAnnotation.image = .init(image: UIImage(named: "greenDiamond")!, name: "greenDiamond")
                    perimeterCoordinates.append(coordinate)
                case "Excluded":
                    pointAnnotation.image = .init(image: UIImage(named: "redDiamond")!, name: "redDiamond")
                    excludedCoordinates.append(coordinate)
                case "Charging":
                    pointAnnotation.image = .init(image: UIImage(named: "blueDiamond")!, name: "blueDiamond")
                    chargingCoordinates.append(coordinate)
                default:
                    break
                }
                
                // Add the PointAnnotation to the array
                pointAnnotations.append(pointAnnotation)
            }
            
            // Create and configure a PointAnnotationManager
            let pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
            pointAnnotationManager.annotations = pointAnnotations
            
            // Create PolylineAnnotations for each entry type
            let perimeterPolyline = PolylineAnnotation(lineCoordinates: perimeterCoordinates)
            let excludedPolyline = PolylineAnnotation(lineCoordinates: excludedCoordinates)
            let chargingPolyline = PolylineAnnotation(lineCoordinates: chargingCoordinates)
            
            // Create and configure a PolylineAnnotationManager
            let polylineManager = mapView.annotations.makePolylineAnnotationManager()
            polylineManager.annotations = [perimeterPolyline, excludedPolyline, chargingPolyline]
            
        } catch {
            // Handle any errors that occur during fetching
            print("Failed to fetch GPS data points: \(error)")
        }
    }
}
