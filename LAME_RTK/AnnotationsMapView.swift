// Import the necessary modules for UI, Mapbox, Core Data, and Core Location
import SwiftUI
import MapboxMaps
import CoreData
import CoreLocation

// Define a SwiftUI view that represents the AnnotationsMapViewController
struct AnnotationsMapView: UIViewControllerRepresentable {
    // Create and return a new AnnotationsMapViewController when the view is made
    func makeUIViewController(context: Context) -> AnnotationsMapViewController {
        return AnnotationsMapViewController()
    }
    
    // Update the AnnotationsMapViewController when there are changes
    func updateUIViewController(_ uiViewController: AnnotationsMapViewController, context: Context) {
    }
}

// Define the AnnotationsMapViewController class
class AnnotationsMapViewController: UIViewController, CLLocationManagerDelegate, AnnotationInteractionDelegate {
    // Declare a MapView variable to hold the Mapbox map
    internal var mapView: MapView!
    
    // Declare a variable for the location manager
    var locationManager: CLLocationManager!
    
    // Declare a variable to check if the map has been centered
    var hasCenteredMap = false
    
    // Fetch the default latitude and longitude from AppStorage
    @AppStorage("defaultLongitude") var defaultLongitude: Double = 0.0
    @AppStorage("defaultLatitude") var defaultLatitude: Double = 0.0
    
    // Declare a variable to hold the Core Data managed object context
    let managedObjectContext = PersistenceController.shared.container.viewContext
    
    // MARK: - Annotation Interaction Delegate Methods
    
    // This function is a delegate method from Mapbox's AnnotationManager.
    // It gets called when an annotation on the map is tapped.
    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        // Check if the first annotation in the array is of type PointAnnotation.
        if let tappedAnnotation = annotations.first as? PointAnnotation {
            // Display an alert showing the coordinates of the tapped annotation.
            let alert = UIAlertController(title: "Annotation Tapped", message: "You tapped an annotation.", preferredStyle: .alert)
            
            // Add an "OK" button to the alert.
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            // Present the alert.
            self.present(alert, animated: true, completion: nil)
        }
    }
 


    
    // MARK: - View Lifecycle Methods
    
    // Function that runs when the view loads.
    // It initializes the Mapbox map, location manager, and other UI elements.
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the location manager and set its delegate
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        // Initialize Mapbox resource options
        let myResourceOptions = ResourceOptions(accessToken: "Your Mapbox Token Here")
        
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
        
        // Add zoom buttons
        addZoomButtons()
    }
    
    // MARK: - Custom Methods

    /**
     This function fetches GPS data points from Core Data and annotates them on the map.
     It also sets up different types of annotations based on the entry type of each data point.
    */
    func fetchAndAnnotateGPSData() {
        // Create a fetch request for the GPSDataPoint entity in Core Data
        let fetchRequest: NSFetchRequest<GPSDataPoint> = GPSDataPoint.fetchRequest()
        
        do {
            // Execute the fetch request and store the results in a variable
            let fetchedResults = try managedObjectContext.fetch(fetchRequest)
            
            // Initialize an empty array to hold PointAnnotation objects
            var pointAnnotations: [PointAnnotation] = []
            
            // Initialize arrays to hold coordinates for each type of entry (Perimeter, Excluded, Charging)
            var perimeterCoordinates: [CLLocationCoordinate2D] = []
            var excludedCoordinates: [CLLocationCoordinate2D] = []
            var chargingCoordinates: [CLLocationCoordinate2D] = []
            
            // Loop through the fetched results to create annotations
            for dataPoint in fetchedResults {
                // Create a coordinate from the latitude and longitude of each data point
                let coordinate = CLLocationCoordinate2DMake(dataPoint.latitude, dataPoint.longitude)
                
                // Create a PointAnnotation object with the coordinate
                var pointAnnotation = PointAnnotation(coordinate: coordinate)
                
                // Assign an image to the annotation based on the entryType
                switch dataPoint.entryType {
                case "Perimeter":
                    if let GreenDiamondImage = UIImage(named: "GreenDiamond") {
                        pointAnnotation.image = .init(image: GreenDiamondImage, name: "GreenDiamond")
                    }
                    perimeterCoordinates.append(coordinate)
                case "Excluded":
                    if let RedDiamondImage = UIImage(named: "RedDiamond") {
                        pointAnnotation.image = .init(image: RedDiamondImage, name: "RedDiamond")
                    }
                    excludedCoordinates.append(coordinate)
                case "Charging":
                    if let BlueDiamondImage = UIImage(named: "BlueDiamond") {
                        pointAnnotation.image = .init(image: BlueDiamondImage, name: "BlueDiamond")
                    }
                    chargingCoordinates.append(coordinate)
                default:
                    break
                }
                
                // Add the created PointAnnotation to the array
                pointAnnotations.append(pointAnnotation)
            }
            
            // Create and configure a PointAnnotationManager to manage the annotations
            let pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
            
            // Assign the array of PointAnnotations to the manager
            pointAnnotationManager.annotations = pointAnnotations
            
            // Set the delegate for the PointAnnotationManager
            pointAnnotationManager.delegate = self  // <-- Add this line here
            
            // Create PolylineAnnotations with different colors
            var perimeterPolyline = PolylineAnnotation(lineCoordinates: perimeterCoordinates)
            perimeterPolyline.lineColor = StyleColor(.green) // Set the line color to green

            var excludedPolyline = PolylineAnnotation(lineCoordinates: excludedCoordinates)
            excludedPolyline.lineColor = StyleColor(.red) // Set the line color to red

            var chargingPolyline = PolylineAnnotation(lineCoordinates: chargingCoordinates)
            chargingPolyline.lineColor = StyleColor(.blue) // Set the line color to blue

            // Create and configure a PolylineAnnotationManager
            let polylineManager = mapView.annotations.makePolylineAnnotationManager()
            polylineManager.annotations = [perimeterPolyline, excludedPolyline, chargingPolyline]

        } catch {
            // Handle any errors that occur during fetching
            print("Failed to fetch GPS data points: \(error)")
        }
    }

    // Function to add zoom buttons to the map.
    func addZoomButtons() {
        // Create zoom in button
        let zoomInButton = UIButton(frame: CGRect(x: 20, y: 20, width: 30, height: 30))
        zoomInButton.setTitle("+", for: .normal)
        zoomInButton.backgroundColor = .white
        zoomInButton.addTarget(self, action: #selector(zoomIn), for: .touchUpInside)
        
        // Create zoom out button
        let zoomOutButton = UIButton(frame: CGRect(x: 20, y: 60, width: 30, height: 30))
        zoomOutButton.setTitle("-", for: .normal)
        zoomOutButton.backgroundColor = .white
        zoomOutButton.addTarget(self, action: #selector(zoomOut), for: .touchUpInside)
        
        // Add buttons to the view
        self.view.addSubview(zoomInButton)
        self.view.addSubview(zoomOutButton)
    }
    
    // Function to handle zoom in button tap.
    @objc func zoomIn() {
        mapView.mapboxMap.setCamera(to: CameraOptions(zoom: mapView.mapboxMap.cameraState.zoom + 1))
    }
    
    // Function to handle zoom out button tap.
    @objc func zoomOut() {
        mapView.mapboxMap.setCamera(to: CameraOptions(zoom: mapView.mapboxMap.cameraState.zoom - 1))
    }
}
