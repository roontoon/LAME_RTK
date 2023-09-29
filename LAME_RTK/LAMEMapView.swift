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
        let myResourceOptions = ResourceOptions(accessToken: "sk.eyJ1Ijoicm9vbnRvb24iLCJhIjoiY2xtamZ1b3UzMDJ4MjJrbDgxMm0ya3prMiJ9.VtLaE_XUfS9QSXa2QREpdQ")
        
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
        // Initialize a UIButton with a frame at x: 20, y: 20 and dimensions 30x30
        let zoomInButton = UIButton(frame: CGRect(x: 20, y: 30, width: 30, height: 30))
        // Set the title of the button to "+"
        zoomInButton.setTitle("+", for: .normal)
        // Set the font size of the title to 18
        zoomInButton.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        // Set the background color of the button to white
        zoomInButton.backgroundColor = .lightGray
        // Set the corner radius of the button to 10, making it rounded
        zoomInButton.layer.cornerRadius = 10
        // Add an action to the button, so when it's tapped, it will call the zoomIn function
        zoomInButton.addTarget(self, action: #selector(zoomIn), for: .touchUpInside)
        
        // Create zoom out button
        // Initialize a UIButton with a frame at x: 20, y: 90 and dimensions 30x30
        let zoomOutButton = UIButton(frame: CGRect(x: 20, y: 70, width: 30, height: 30))
        // Set the title of the button to "-"
        zoomOutButton.setTitle("-", for: .normal)
        // Set the font size of the title to 18
        zoomOutButton.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        // Set the background color of the button to white
        zoomOutButton.backgroundColor = .lightGray
        // Set the corner radius of the button to 10, making it rounded
        zoomOutButton.layer.cornerRadius = 10
        // Add an action to the button, so when it's tapped, it will call the zoomOut function

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
