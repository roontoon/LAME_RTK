// AnnotationsMapView.swift
// Date and Time Documented: October 21, 2023, 11:00 AM
//
// This file defines a SwiftUI view and a UIViewController that handles the Mapbox map annotations.
// It fetches GPS data points from Core Data, displays them as annotations on the map,
// allows users to edit latitude and longitude directly in the annotation's popup window,
// and refreshes the map after editing.

// Import the necessary modules for UI, Mapbox, Core Data, and Core Location
import SwiftUI
import MapboxMaps
import CoreData
import CoreLocation

// MARK: - MapIDSelectionDelegate Protocol Definition
/// A protocol to handle the selection of a Map ID.
protocol MapIDSelectionDelegate: AnyObject {
    func didSelectMapID(_ selectedMapID: String)
}

func didSelectMapID(_ selectedMapID: String) {
    print("***** Debug: didSelectMapID called with \(selectedMapID)")
}

// MARK: - AnnotationsMapControllerRepresentable Struct Definition
/// This struct helps in making AnnotationsMapViewController compatible with SwiftUI. It conforms to the UIViewControllerRepresentable protocol to create and manage a UIKit view controller in a SwiftUI view hierarchy.
struct AnnotationsMapControllerRepresentable: UIViewControllerRepresentable {
    
    var selectedMapID: String
    var fetchedResults: FetchedResults<GPSDataPoint>  // Declare this property to hold fetched results
    
    // MARK: - UIViewControllerRepresentable Methods
    /// This function is responsible for creating a new AnnotationsMapViewController instance. SwiftUI calls this method when it is ready to display the view and manages its lifecycle.
    func makeUIViewController(context: Context) -> AnnotationsMapViewController {
        return AnnotationsMapViewController(selectedMapID: selectedMapID, fetchedResults: fetchedResults)  // Pass the fetchedResults here
    }
    
    /// SwiftUI calls this method to update the already created UIViewController when a state or binding variable that this view relies upon updates.
    /// For now, it's empty as we don't have dynamic changes that affect the AnnotationsMapViewController. If you want to handle dynamic changes, you can add logic here.
    func updateUIViewController(_ uiViewController: AnnotationsMapViewController, context: Context) {
        // Update logic, if needed
    }
}

// MARK: - AnnotationsMapContainerView Struct Definition
/// This SwiftUI view serves as a container for both the AnnotationsMapViewController and the MapIDPickerBody.
/// It ensures that the picker floats over the map view.
struct AnnotationsMapView: View {
    
    // MARK: - Properties and Variables
    /// Declare a state for managing the selected Map ID
    @State var selectedMapID: String = "Pick a map"  // Replace with your default Map ID
    
    /// FetchRequest to get mapIDs from Core Data
    @FetchRequest(
        entity: GPSDataPoint.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \GPSDataPoint.mapID, ascending: true)]
    ) var fetchedResults: FetchedResults<GPSDataPoint>
    
    // Compute unique map IDs
    var uniqueMapIDs: [String] {
        Array(Set(fetchedResults.compactMap { $0.mapID })).sorted()
    }
    
    /// Declare a delegate to handle Map ID selection
    weak var mapIDDelegate: MapIDSelectionDelegate?
    
    // MARK: - Body Definition
    /// The body of the AnnotationsMapContainerView.
    var body: some View {
        ZStack(alignment: .bottomTrailing) {  // Explicit alignment
            // Map as a background
            AnnotationsMapControllerRepresentable(selectedMapID: selectedMapID, fetchedResults: fetchedResults)  // Pass the fetchedResults here
                .edgesIgnoringSafeArea(.all)
            
            // Floating Picker as an overlay
            VStack {
                Spacer() // Pushes the picker to the bottom
                MapIDPickerBody(selectedMapID: $selectedMapID, mapIDs: ["Pick a map"] + uniqueMapIDs)
                    .background(Color.white.opacity(0.0)) // Adjust opacity here
                    .cornerRadius(10)
                    .padding(0)
            }
        }
        .onAppear {
            print("**** AnnotationsMapContainerView appeared")
            print("**** Unique Map IDs: \(["Pick a map"] + uniqueMapIDs)")  // Debug statement to check uniqueMapIDs
            if let lastSelectedMapID = UserDefaults.standard.string(forKey: "lastSelectedMapID") {
                selectedMapID = lastSelectedMapID}
        }
        .onChange(of: selectedMapID) { newValue in
            print("**** selectedMapID changed to: \(newValue)")
            UserDefaults.standard.setValue(newValue, forKey: "lastSelectedMapID")

            // Notify AnnotationsMapViewController about the change in selectedMapID
            NotificationCenter.default.post(name: Notification.Name("SelectedMapIDChanged"), object: nil, userInfo: ["selectedMapID": newValue])
        }
    }
}


// MARK: - AnnotationsMapViewController Class Definition
/// Define the AnnotationsMapViewController class
class AnnotationsMapViewController: UIViewController, CLLocationManagerDelegate, AnnotationInteractionDelegate {
    
    // MARK: - Properties and Variables
    /// Declare a MapView variable to hold the Mapbox map
    internal var mapView: MapView!
    
    /// Declare a variable to hold the fetched map IDs
    var mapIDs: [String] = []
    
    /// Declare a variable to manage Point Annotations
    var pointAnnotationManager: PointAnnotationManager?
    
    /// Declare a variable to manage Polyline Annotations
    var polylineAnnotationManager: PolylineAnnotationManager?
    
    /// Declare a variable for the location manager
    var locationManager: CLLocationManager!
    
    /// Declare a variable to check if the map has been centered
    var hasCenteredMap = false
    
    /// Initialize an empty set to hold unique map IDs
    var uniqueMapIDs = Set<String>()
    
    var selectedMapID: String
    var fetchedResults: FetchedResults<GPSDataPoint>  // Declare this property to hold fetched results
    
    // Custom initializer that accepts selectedMapID and fetchedResults
    init(selectedMapID: String, fetchedResults: FetchedResults<GPSDataPoint>) {
        self.selectedMapID = selectedMapID
        self.fetchedResults = fetchedResults  // Initialize fetchedResults here
        super.init(nibName: nil, bundle: nil)  // Call super.init after all properties are initialized
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Fetch the default latitude and longitude from AppStorage
    @AppStorage("defaultLongitude") var defaultLongitude: Double = 0.0
    @AppStorage("defaultLatitude") var defaultLatitude: Double = 0.0
    
    /// Declare a variable to hold the Core Data managed object context
    let managedObjectContext = PersistenceController.shared.container.viewContext
    // MARK: - Annotation Interaction Delegate Methods
    /// This function is a delegate method from Mapbox's AnnotationManager.
    /// It gets called when an annotation on the map is tapped.
    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        print("***** Tapped on annotation: \(annotations)") // Debug print
        // Check if the first annotation in the array is a PointAnnotation.
        if let tappedAnnotation = annotations.first as? PointAnnotation {
            // Verify if userInfo of tappedAnnotation has data.
            if let userInfo = tappedAnnotation.userInfo {
                // Extract latitude and longitude from userInfo.
                if let latitude = userInfo["latitude"] as? Double,
                   let longitude = userInfo["longitude"] as? Double,
                   let objectID = userInfo["objectID"] as? NSManagedObjectID { // New: fetch objectID
                    // Create an alert to display and edit the coordinates when an annotation is tapped.
                    let alert = UIAlertController(title: "Edit Annotation", message: "Edit latitude and longitude.", preferredStyle: .alert)
                    // Add text fields for latitude and longitude.
                    alert.addTextField { (textField) in
                        textField.placeholder = "Latitude"
                        textField.text = "\(latitude)"
                    }
                    alert.addTextField { (textField) in
                        textField.placeholder = "Longitude"
                        textField.text = "\(longitude)"
                    }
                    // Add a "Cancel" button to the alert.
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    // Add a "Save" button to the alert.
                    alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
                        if let latText = alert.textFields?[0].text, let lonText = alert.textFields?[1].text {
                            if let newLat = Double(latText), let newLon = Double(lonText) {
                                self.updateGPSDataPoint(objectID: objectID, newLat: newLat, newLon: newLon) // Will define this method later
                            }
                        }
                    }))
                    // Present the alert.
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    /**
     Updates the latitude and longitude of a GPSDataPoint in Core Data and commits the changes.
     Also refreshes the map to reflect these changes.
     */
    func updateGPSDataPoint(objectID: NSManagedObjectID, newLat: Double, newLon: Double) {
        do {
            /// Fetch the GPSDataPoint object from Core Data using its objectID
            if let objectToUpdate = try managedObjectContext.existingObject(with: objectID) as? GPSDataPoint {
                
                /// Update the latitude and longitude fields of the object
                objectToUpdate.latitude = newLat
                objectToUpdate.longitude = newLon
                
                /// Commit the changes to the managed object context
                try managedObjectContext.save()
                
                /// Refresh the map to reflect the changes by calling fetchAndAnnotateGPSData()
                fetchAndAnnotateGPSData()
                
            }
        } catch {
            /// Handle any errors that occur during fetching or saving
            print("***** Failed to update GPS data point: \(error)")
        }
    }
    
    /**
     Fetches GPS data points from Core Data and annotates them on the map.
     It also sets up different types of annotations based on the entry type of each data point.
     */
    // MARK: - Core Data Fetch and Annotation
    /**
     Fetches GPS data points from Core Data and annotates them on the map.
     It also sets up different types of annotations based on the entry type of each data point.
     Additionally, it fetches unique map IDs from the Core Data and stores them in the mapIDs array.
     */
    func fetchAndAnnotateGPSData() {
        
        // Clear the map if the selected map is "Pick a map"
        if selectedMapID == "Pick a map" {
            pointAnnotationManager?.annotations = []
            polylineAnnotationManager?.annotations = []
            return
        }
        
        print("***** Debug: Inside fetchAndAnnotateGPSData")
        
        // Create a fetch request for the GPSDataPoint entity in Core Data
        let fetchRequest: NSFetchRequest<GPSDataPoint> = GPSDataPoint.fetchRequest()
        
        // Add a predicate to filter by selected Map ID
        let predicate = NSPredicate(format: "mapID == %@", selectedMapID)
        fetchRequest.predicate = predicate
        
        // Debug: Print the count of fetched records
        print("*****Debug: Number of fetched records: \(fetchedResults.count)")
        
        
        // Initialize an empty set to hold unique map IDs
        var uniqueMapIDs = Set<String>()
        
        do {
            let fetchedResults = try self.managedObjectContext.fetch(fetchRequest)
            
            // Debug: Print the count of fetched records
            print("***** Debug: Number of fetched records: \(fetchedResults.count)")
            
            // Sort fetchedResults
            let sortedResults = fetchedResults.sorted {
                guard let mapID1 = $0.mapID, let mapID2 = $1.mapID else { return false }
                if mapID1 == mapID2 {
                    guard let entryType1 = $0.entryType, let entryType2 = $1.entryType else { return false }
                    if entryType1 == entryType2 {
                        return ($0.dataPointCount ?? 0) < ($1.dataPointCount ?? 0)
                    }
                    return entryType1 < entryType2
                }
                return mapID1 < mapID2
            }
            
            // Print sorted data points
            for dataPoint in sortedResults {
                print("***** Latitude: \(dataPoint.latitude), Longitude: \(dataPoint.longitude), MapID: \(String(describing: dataPoint.mapID)), EntryType: \(String(describing: dataPoint.entryType)), DataPointCount: \(String(describing: dataPoint.dataPointCount))")
            }
            // Initialize an empty array to hold PointAnnotation objects
            var pointAnnotations: [PointAnnotation] = []
            
            // Initialize arrays to hold coordinates for different types of entries: Perimeter, Excluded, and Charging
            var perimeterCoordinates: [CLLocationCoordinate2D] = []
            var excludedCoordinates: [CLLocationCoordinate2D] = []
            var chargingCoordinates: [CLLocationCoordinate2D] = []
            
            // Loop through the fetched results to create annotations and collect map IDs
            for dataPoint in fetchedResults {
                // Create a coordinate using the latitude and longitude of each data point
                let coordinate = CLLocationCoordinate2DMake(dataPoint.latitude, dataPoint.longitude)
                
                // Create a PointAnnotation object with the coordinate
                var pointAnnotation = PointAnnotation(coordinate: coordinate)
                
                // Populate the userInfo dictionary with latitude, longitude, and Core Data objectID
                pointAnnotation.userInfo = ["latitude": dataPoint.latitude, "longitude": dataPoint.longitude, "objectID": dataPoint.objectID]
                
                // Determine the image for the annotation based on the entryType
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
                
                // Collect unique map IDs
                if let mapID = dataPoint.mapID {
                    uniqueMapIDs.insert(mapID)
                }
            }
            
            // Update the mapIDs variable with unique map IDs
            self.mapIDs = Array(uniqueMapIDs)
            
            // Assign the array of PointAnnotations to the manager
            pointAnnotationManager?.annotations = pointAnnotations
            
            // Create PolylineAnnotations for different types: Perimeter, Excluded, and Charging
            var perimeterPolyline = PolylineAnnotation(lineCoordinates: perimeterCoordinates)
            perimeterPolyline.lineColor = StyleColor(.green)
            
            var excludedPolyline = PolylineAnnotation(lineCoordinates: excludedCoordinates)
            excludedPolyline.lineColor = StyleColor(.red)
            
            var chargingPolyline = PolylineAnnotation(lineCoordinates: chargingCoordinates)
            chargingPolyline.lineColor = StyleColor(.blue)
            
            // Assign the PolylineAnnotations to the PolylineAnnotationManager
            polylineAnnotationManager?.annotations = [perimeterPolyline, excludedPolyline, chargingPolyline]
            
        } catch {
            // Print any errors that occur during fetching
            print("***** Failed to fetch GPS data points: \(error)")
            
        }
    }
    
    // In AnnotationsMapViewController Class Definition
    /*func didSelectMapID(_ selectedMapID: String) {
     print("***** Debug: didSelectMapID called with \(selectedMapID)")
     self.selectedMapID = selectedMapID
     print("***** Debug: self.selectedMapID updated to \(self.selectedMapID)")
     fetchAndAnnotateGPSData()
     print("***** Debug: fetchAndAnnotateGPSData called")
     }
     */
    
    // MARK: - MapIDSelectionDelegate Conformance
    /// Function to update the selected Map ID.
    func didSelectMapID(_ selectedMapID: String) {
        print("***** New Map ID selected: \(selectedMapID)")
        self.selectedMapID = selectedMapID  // Update the selected Map ID
        
        // Clear the map if the selected map is "Pick a map"
        if selectedMapID == "Pick a map" {
            pointAnnotationManager?.annotations = []
            polylineAnnotationManager?.annotations = []
            return
        }
        fetchAndAnnotateGPSData()  // Refresh the map annotations
    }
    
    // MARK: - Observers
    /// Subscribe to changes in the selected Map ID
    func subscribeToSelectedMapIDChanges() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleSelectedMapIDChange(notification:)), name: Notification.Name("SelectedMapIDChanged"), object: nil)
    }
    
    /// Function to handle the selected Map ID change
    @objc func handleSelectedMapIDChange(notification: Notification) {
        if let newMapID = notification.userInfo?["selectedMapID"] as? String {
            self.selectedMapID = newMapID
            fetchAndAnnotateGPSData()
        }
    }
    
    
    // MARK: - View Lifecycle Methods
    /// Function that runs when the view loads.
    /// It initializes the Mapbox map, location manager, and other UI elements.
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        print("***** Debug: viewDidLoad started")
        
        // Initialize UI and Managers
        initializeLocationManager()
        initializeMapView()
        print("***** Debug: mapView initialized = \(mapView != nil)")
        
        // Initialize annotation managers
        initializeAnnotationManagers()  // New function to initialize annotation managers
        
        // Fetch and annotate GPS data points
        fetchAndAnnotateGPSData()
        
        subscribeToSelectedMapIDChanges()
        
        // Add zoom buttons
        addZoomButtons()
        
        /// Declare a variable to hold the selected Map ID
        var selectedMapID: String = "SecondMap" // Default value, update as necessary
        
        // Add SwiftUI Picker overlay
        let picker = UIHostingController(rootView: MapIDPickerBody(selectedMapID: .constant(selectedMapID), mapIDs: mapIDs))
        addChild(picker)
        view.addSubview(picker.view)
        picker.didMove(toParent: self)
        
        print("***** Debug: viewDidLoad completed")
    }
    
    
    /// Initializes the Location Manager and requests user authorization for location access.
    func initializeLocationManager() {
        locationManager = CLLocationManager()  // Initialize CLLocationManager
        locationManager.delegate = self  // Set the delegate to self
        locationManager.requestWhenInUseAuthorization()  // Request permission to access location
    }
    
    /// Initializes the Mapbox MapView and adds it to the view hierarchy.
    func initializeMapView() {
        // Provide the Mapbox access token, camera options, and map style
        let myResourceOptions = ResourceOptions(accessToken: "sk.eyJ1Ijoicm9vbnRvb24iLCJhIjoiY2xtamZ1b3UzMDJ4MjJrbDgxMm0ya3prMiJ9.VtLaE_XUfS9QSXa2QREpdQ")
        
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: defaultLatitude, longitude: defaultLongitude), zoom: 19)
        let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions, cameraOptions: cameraOptions, styleURI: .streets)
        
        // Initialize MapView with the given options
        mapView = MapView(frame: view.bounds, mapInitOptions: myMapInitOptions)
        
        // Enable autoresizing
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Add MapView to the main view
        self.view.addSubview(mapView)
    }
    
    
    /// Initializes the annotation managers for point and polyline annotations.
    /// This function should be called after the mapView is initialized.
    func initializeAnnotationManagers() {
        if mapView != nil {  // Check if mapView is not nil
            pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
            pointAnnotationManager?.delegate = self  // Set delegate to self for annotation interactions
            
            polylineAnnotationManager = mapView.annotations.makePolylineAnnotationManager()
            polylineAnnotationManager?.delegate = self  // Set delegate to self for annotation interactions
        } else {
            print("***** Error: mapView is nil. Annotation managers not initialized.")
        }
    }
    
    
    // MARK: - UI Customization Methods
    /// Contains methods for customizing the UI, such as adding zoom buttons.
    
    /// Function to add zoom buttons to the map.
    @objc func addZoomButtons() {
        /// Create a zoom in button with a "+" label.
        let zoomInButton = UIButton(frame: CGRect(x: 20, y: 20, width: 30, height: 30))
        zoomInButton.setTitle("+", for: .normal)
        zoomInButton.backgroundColor = .white
        
        /// Add an action for the zoom in button. It calls the 'zoomIn()' function when pressed.
        zoomInButton.addTarget(self, action: #selector(zoomIn), for: .touchUpInside)
        
        /// Create a zoom out button with a "-" label.
        let zoomOutButton = UIButton(frame: CGRect(x: 20, y: 60, width: 30, height: 30))
        zoomOutButton.setTitle("-", for: .normal)
        zoomOutButton.backgroundColor = .white
        
        /// Add an action for the zoom out button. It calls the 'zoomOut()' function when pressed.
        zoomOutButton.addTarget(self, action: #selector(zoomOut), for: .touchUpInside)
        
        /// Add the zoom buttons to the view.
        self.view.addSubview(zoomInButton)
        self.view.addSubview(zoomOutButton)
    }
    
    /// Function to handle zoom in button tap.
    @objc func zoomIn() {
        /// Increase the map's zoom level by 1.
        mapView.mapboxMap.setCamera(to: CameraOptions(zoom: mapView.mapboxMap.cameraState.zoom + 1))
    }
    
    /// Function to handle zoom out button tap.
    @objc func zoomOut() {
        /// Decrease the map's zoom level by 1.
        mapView.mapboxMap.setCamera(to: CameraOptions(zoom: mapView.mapboxMap.cameraState.zoom - 1))
    }
}

