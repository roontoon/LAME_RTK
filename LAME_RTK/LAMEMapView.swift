/*// Import the necessary modules for UI, Mapbox, and Core Data
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
        
        // Add double-click to zoom functionality
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(doubleTap)
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
                    // Safely unwrap the image asset with capitalized color name
                    if let GreenDiamondImage = UIImage(named: "GreenDiamond") {
                        pointAnnotation.image = .init(image: GreenDiamondImage, name: "GreenDiamond")
                    }
                    // Add the coordinate to the perimeterCoordinates array
                    perimeterCoordinates.append(coordinate)
                case "Excluded":
                    // Safely unwrap the image asset with capitalized color name
                    if let RedDiamondImage = UIImage(named: "RedDiamond") {
                        pointAnnotation.image = .init(image: RedDiamondImage, name: "RedDiamond")
                    }
                    // Add the coordinate to the excludedCoordinates array
                    excludedCoordinates.append(coordinate)
                case "Charging":
                    // Safely unwrap the image asset with capitalized color name
                    if let BlueDiamondImage = UIImage(named: "BlueDiamond") {
                        pointAnnotation.image = .init(image: BlueDiamondImage, name: "BlueDiamond")
                    }
                    // Add the coordinate to the chargingCoordinates array
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
    
    // Function to add zoom buttons to the map
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
    
    // Function to handle zoom in button tap
    @objc func zoomIn() {
        mapView.mapboxMap.setCamera(to: CameraOptions(zoom: mapView.mapboxMap.cameraState.zoom + 1))
    }
    
    // Function to handle zoom out button tap
    @objc func zoomOut() {
        mapView.mapboxMap.setCamera(to: CameraOptions(zoom: mapView.mapboxMap.cameraState.zoom - 1))
    }
    
    // Function to handle double tap gesture
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: mapView)
        let coordinate = mapView.mapboxMap.coordinate(for: point)
        mapView.mapboxMap.setCamera(to: CameraOptions(center: coordinate, zoom: mapView.mapboxMap.cameraState.zoom + 1))
    }
}
*/
