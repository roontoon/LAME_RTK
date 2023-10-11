/// AnnotationsMapView.swift
/// Date and Time Documented: October 9, 2023, 3:00 PM
///
/// This file defines a SwiftUI view and a UIViewController that handles the Mapbox map annotations.
/// It fetches GPS data points from Core Data, displays them as annotations on the map,
/// and allows users to edit latitude and longitude directly in the annotation's popup window.

/// Import the necessary modules for UI, Mapbox, Core Data, and Core Location
import SwiftUI
import MapboxMaps
import CoreData
import CoreLocation

// MARK: - SwiftUI View for AnnotationsMapViewController
/// Define a SwiftUI view that represents the AnnotationsMapViewController
struct AnnotationsMapView: UIViewControllerRepresentable {
    /// Create and return a new AnnotationsMapViewController when the view is made
    func makeUIViewController(context: Context) -> AnnotationsMapViewController {
        return AnnotationsMapViewController()
    }
    
    /// Update the AnnotationsMapViewController when there are changes
    func updateUIViewController(_ uiViewController: AnnotationsMapViewController, context: Context) {
    }
}

// MARK: - AnnotationsMapViewController Class Definition
/// Define the AnnotationsMapViewController class
class AnnotationsMapViewController: UIViewController, CLLocationManagerDelegate, AnnotationInteractionDelegate {

    // MARK: - Properties and Variables
    /// Declare a MapView variable to hold the Mapbox map
    internal var mapView: MapView!
    
    /// Declare a variable for the location manager
    var locationManager: CLLocationManager!
    
    /// Declare a variable to check if the map has been centered
    var hasCenteredMap = false
    
    /// Fetch the default latitude and longitude from AppStorage
    @AppStorage("defaultLongitude") var defaultLongitude: Double = 0.0
    @AppStorage("defaultLatitude") var defaultLatitude: Double = 0.0
    
    /// Declare a variable to hold the Core Data managed object context
    let managedObjectContext = PersistenceController.shared.container.viewContext

    // MARK: - Annotation Interaction Delegate Methods
    /**
     This function is a delegate method from Mapbox's AnnotationManager.
     It gets called when an annotation on the map is tapped.
    */
    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        
        /// Check if the first annotation in the array is of type PointAnnotation.
        if let tappedAnnotation = annotations.first as? PointAnnotation {
            
            /// Verify if `userInfo` of `tappedAnnotation` has data.
            if let userInfo = tappedAnnotation.userInfo {
                
                /// Extract the latitude and longitude from userInfo.
                if let latitude = userInfo["latitude"] as? Double,
                   let longitude = userInfo["longitude"] as? Double,
                   let objectID = userInfo["objectID"] as? NSManagedObjectID { // New: fetch objectID
                    
                    /// Create an alert to display and edit the coordinates when an annotation is tapped.
                    let alert = UIAlertController(title: "Edit Annotation", message: "Edit latitude and longitude.", preferredStyle: .alert)
                    
                    /// Add text fields for latitude and longitude.
                    alert.addTextField { (textField) in
                        textField.placeholder = "Latitude"
                        textField.text = "\(latitude)"
                    }
                    alert.addTextField { (textField) in
                        textField.placeholder = "Longitude"
                        textField.text = "\(longitude)"
                    }
                    
                    /// Add a "Cancel" button to the alert.
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    
                    /// Add a "Save" button to the alert.
                    alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
                        if let latText = alert.textFields?[0].text, let lonText = alert.textFields?[1].text {
                            if let newLat = Double(latText), let newLon = Double(lonText) {
                                self.updateGPSDataPoint(objectID: objectID, newLat: newLat, newLon: newLon)
                            }
                        }
                    }))
                    
                    /// Present the alert.
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    // MARK: - View Lifecycle Methods
    /// Function that runs when the view loads.
    /// It initializes the Mapbox map, location manager, and other UI elements.
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize UI and Managers
        initializeLocationManager()
        initializeMapView()
        
        // Fetch and annotate GPS data points
        fetchAndAnnotateGPSData()
        
        // Add zoom buttons
        addZoomButtons()
    }
    
    // MARK: - Custom Initialization Methods
    /// Initializes the Location Manager and requests user authorization for location access.
    func initializeLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Initializes the Mapbox MapView and adds it to the view hierarchy.
    func initializeMapView() {
        let myResourceOptions = ResourceOptions(accessToken: "Your Mapbox Token Here")
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: defaultLatitude, longitude: defaultLongitude), zoom: 19)
        let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions, cameraOptions: cameraOptions, styleURI: .streets)
        mapView = MapView(frame: view.bounds, mapInitOptions: myMapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(mapView)
    }

    // MARK: - Fetch and Annotate GPS Data
    /// Fetches GPS data points from Core Data and annotates them on the map.
    /// It also sets up different types of annotations based on the entry type of each data point.
    func fetchAndAnnotateGPSData() {
        /// Create a fetch request for the GPSDataPoint entity in Core Data
        let fetchRequest: NSFetchRequest<GPSDataPoint> = GPSDataPoint.fetchRequest()
        
        do {
            /// Execute the fetch request and store the results in a variable
            let fetchedResults = try managedObjectContext.fetch(fetchRequest)
            
            /// Initialize an empty array to hold PointAnnotation objects
            var pointAnnotations: [PointAnnotation] = []
            
            /// Initialize arrays to hold coordinates for each type of entry (Perimeter, Excluded, Charging)
            var perimeterCoordinates: [CLLocationCoordinate2D] = []
            var excludedCoordinates: [CLLocationCoordinate2D] = []
            var chargingCoordinates: [CLLocationCoordinate2D] = []
            
            /// Loop through the fetched results to create annotations
            for dataPoint in fetchedResults {
                /// Create a coordinate from the latitude and longitude of each data point
                let coordinate = CLLocationCoordinate2DMake(dataPoint.latitude, dataPoint.longitude)
                
                /// Create a PointAnnotation object with the coordinate
                var pointAnnotation = PointAnnotation(coordinate: coordinate)
                
                /// Populate the userInfo dictionary with latitude, longitude, and Core Data objectID
                pointAnnotation.userInfo = ["latitude": dataPoint.latitude, "longitude": dataPoint.longitude, "objectID": dataPoint.objectID]
                
                /// Assign an image to the annotation based on the entryType
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
                
                /// Add the created PointAnnotation to the array
                pointAnnotations.append(pointAnnotation)
            }
            
            /// Create and configure a PointAnnotationManager to manage the annotations
            let pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
            
            /// Assign the array of PointAnnotations to the manager
            pointAnnotationManager.annotations = pointAnnotations
            
            /// Set the delegate for the PointAnnotationManager
            pointAnnotationManager.delegate = self
            
            /// Create PolylineAnnotations with different colors
            var perimeterPolyline = PolylineAnnotation(lineCoordinates: perimeterCoordinates)
            perimeterPolyline.lineColor = StyleColor(.green)
            
            var excludedPolyline = PolylineAnnotation(lineCoordinates: excludedCoordinates)
            excludedPolyline.lineColor = StyleColor(.red)
            
            var chargingPolyline = PolylineAnnotation(lineCoordinates: chargingCoordinates)
            chargingPolyline.lineColor = StyleColor(.blue)
            
            /// Create and configure a PolylineAnnotationManager
            let polylineManager = mapView.annotations.makePolylineAnnotationManager()
            polylineManager.annotations = [perimeterPolyline, excludedPolyline, chargingPolyline]
            
        } catch {
            /// Handle any errors that occur during fetching
            print("Failed to fetch GPS data points: \(error)")
        }
    }

    // MARK: - Core Data Update Method
    /// Updates the latitude and longitude of a GPSDataPoint in Core Data and commits the changes.
    func updateGPSDataPoint(objectID: NSManagedObjectID, newLat: Double, newLon: Double) {
        do {
            /// Fetch the GPSDataPoint object from Core Data using its objectID
            if let objectToUpdate = try managedObjectContext.existingObject(with: objectID) as? GPSDataPoint {
                
                /// Update the latitude and longitude fields of the object
                objectToUpdate.latitude = newLat
                objectToUpdate.longitude = newLon
                
                /// Commit the changes to the managed object context
                try managedObjectContext.save()
            }
        } catch {
            /// Handle any errors that occur during fetching or saving
            print("Failed to update GPS data point: \(error)")
        }
    }

    // MARK: - UI Customization Methods
    /// Function to add zoom buttons to the map.
    func addZoomButtons() {
        let zoomInButton = UIButton(frame: CGRect(x: 20, y: 20, width: 30, height: 30))
        zoomInButton.setTitle("+", for: .normal)
        zoomInButton.backgroundColor = .white
        zoomInButton.addTarget(self, action: #selector(zoomIn), for: .touchUpInside)
        
        let zoomOutButton = UIButton(frame: CGRect(x: 20, y: 60, width: 30, height: 30))
        zoomOutButton.setTitle("-", for: .normal)
        zoomOutButton.backgroundColor = .white
        zoomOutButton.addTarget(self, action: #selector(zoomOut), for: .touchUpInside)
        
        self.view.addSubview(zoomInButton)
        self.view.addSubview(zoomOutButton)
    }
    
    /// Function to handle zoom in button tap.
    @objc func zoomIn() {
        mapView.mapboxMap.setCamera(to: CameraOptions(zoom: mapView.mapboxMap.cameraState.zoom + 1))
    }
    
    /// Function to handle zoom out button tap.
    @objc func zoomOut() {
        mapView.mapboxMap.setCamera(to: CameraOptions(zoom: mapView.mapboxMap.cameraState.zoom - 1))
    }
}
