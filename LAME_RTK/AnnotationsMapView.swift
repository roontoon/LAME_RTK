/// AnnotationsMapView.swift
/// Date and Time Documented: October 17, 2023, 12:00 PM
///
/// This file defines a SwiftUI view and a UIViewController for handling Mapbox map annotations.
/// It fetches GPS data points from Core Data, displays them as annotations on the map,
/// allows users to edit latitude and longitude directly in the annotation's popup window,
/// and includes a Picker for selecting Map IDs.

// Import the necessary modules for UI, Mapbox, Core Data, and Core Location
import SwiftUI
import MapboxMaps
import CoreData
import CoreLocation

// MARK: - MapIDPicker Struct Definition (Without Body)
/// This struct defines a SwiftUI Picker for selecting Map IDs.
/// It holds an array of Map IDs and a closure that is called when a new Map ID is selected.
/// The Picker's appearance and behavior are configured here.
struct MapIDPicker: View {
    
    // MARK: - Properties and Variables
    /// An array of strings representing the available Map IDs.
    var mapIDs: [String]
    
    /// A closure that takes the newly selected Map ID as a parameter.
    var onSelectionChanged: (String) -> Void
    
    /// A state variable to hold the currently selected Map ID.
    @State internal var selectedMapID: String
    
    // MARK: - Initializer
    /// Initializes the MapIDPicker with the given mapIDs and onSelectionChanged closure.
    ///
    /// - Parameters:
    ///   - mapIDs: An array of strings representing the available Map IDs.
    ///   - onSelectionChanged: A closure that will be called when the selected Map ID changes.
    init(mapIDs: [String], onSelectionChanged: @escaping (String) -> Void) {
        self.mapIDs = mapIDs
        self.onSelectionChanged = onSelectionChanged
        self._selectedMapID = State(initialValue: mapIDs.first ?? "")
    }
}



// MARK: - AnnotationsMapViewController Class Definition
/// Define the AnnotationsMapViewController class
///
///
@objcMembers
class AnnotationsMapViewController: UIViewController, CLLocationManagerDelegate, AnnotationInteractionDelegate {
    
    // MARK: - Properties and Variables
    /// Declare a MapView variable to hold the Mapbox map
    internal var mapView: MapView!
    
    
    // MARK: - Debugging Option
    /// Set this variable to true to enable debugging print statements, or false to disable them.
    var debugMode: Bool = true
    
    /// Declare a variable to manage Point Annotations
    var pointAnnotationManager: PointAnnotationManager?
    
    /// Declare a variable to manage Polyline Annotations
    var polylineAnnotationManager: PolylineAnnotationManager?
    
    /// Declare a variable for the location manager
    var locationManager: CLLocationManager!
    
    /// Declare a variable to check if the map has been centered
    var hasCenteredMap = false
    
    /// Declare a variable to o store unique mapIDs
    var mapIDs: [String] = ["Pick a Map"]  // Initialize with default "Pick a Map" value
    
    var selectedMapID: String?  // Add this line to keep track of the selected map ID
    
    // var mapIDs: [String] = []  // This will hold the unique mapIDs fetched from Core Data
    
    var pickerHostingController: UIHostingController<MapIDPicker>? = nil
    
    /// Fetch the default latitude and longitude from AppStorage
    @AppStorage("defaultLongitude") var defaultLongitude: Double = 0.0
    @AppStorage("defaultLatitude") var defaultLatitude: Double = 0.0
    
    /// Declare a variable to hold the Core Data managed object context
    ///
    let managedObjectContext = PersistenceController.shared.container.viewContext


    // MARK: - Annotation Interaction Delegate Methods
    /// This function is a delegate method from Mapbox's AnnotationManager.
    /// It gets called when an annotation on the map is tapped.
    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        debugPrint("Tapped on annotation: \(annotations)")
        
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
                        textField.keyboardType = .decimalPad  // Set keyboard type to decimal pad
                    }
                    alert.addTextField { (textField) in
                        textField.placeholder = "Longitude"
                        textField.text = "\(longitude)"
                        textField.keyboardType = .decimalPad  // Set keyboard type to decimal pad
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
        debugPrint("***** updateGPSDataPoint called")
        do {
            /// Fetch the GPSDataPoint object from Core Data using its objectID
            if let objectToUpdate = try managedObjectContext.existingObject(with: objectID) as? GPSDataPoint {
                
                /// Update the latitude and longitude fields of the object
                objectToUpdate.latitude = newLat
                objectToUpdate.longitude = newLon
                
                /// Commit the changes to the managed object context
                try managedObjectContext.save()
                
                /// Refresh the map to reflect the changes by calling fetchAndAnnotateGPSData()
                //fetchAndAnnotateGPSData(mapID: self.selectedMapID)
                fetchAndAnnotateGPSData()
            }
        } catch {
            /// Handle any errors that occur during fetching or saving
            print("Failed to update GPS data point: \(error)")
        }
    }
    
    
    
    // MARK: - Fetch and Annotate GPS Data
    
    /**
     Fetches GPS data points for the selected mapID from Core Data and annotates them on the map.
     
     This function fetches all GPSDataPoint records from Core Data that match the currently selected mapID.
     It then annotates these points on the Mapbox map, along with creating polylines for different entry types.
     
     - Parameters: None
     - Returns: None
     */
    func fetchAndAnnotateGPSData() {
        
        /// Create a fetch request for the GPSDataPoint entity in Core Data
        let fetchRequest: NSFetchRequest<GPSDataPoint> = GPSDataPoint.fetchRequest()
        
        /// Check if the PointAnnotationManager has been initialized, if not, initialize it
        if pointAnnotationManager == nil {
            pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
            debugPrint("***** Debug: pointAnnotationManager initialized")
        }
        
        /// Set the delegate for the PointAnnotationManager
        pointAnnotationManager?.delegate = self
        debugPrint("***** Debug: pointAnnotationManager delegate set to self")
        
        // Debugging statement to print the mapID for which data is being fetched
        debugPrint("***** fetchAndAnnotateGPSData called for mapID: \(self.selectedMapID ?? "None")")
        
        /*        /// Create a fetch request for the GPSDataPoint entity in Core Data
         let fetchRequest: NSFetchRequest<GPSDataPoint> = GPSDataPoint.fetchRequest()
         */
        
        // Add a predicate to filter by the selected mapID
        if let currentMapID = self.selectedMapID {
            fetchRequest.predicate = NSPredicate(format: "mapID == %@", currentMapID)
        }
        
        // MARK: Modification - Adding Sort Descriptors
        let sortDescriptor1 = NSSortDescriptor(key: "mapID", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "entryType", ascending: true)
        let sortDescriptor3 = NSSortDescriptor(key: "dataPointCount", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2, sortDescriptor3]
        
        do {
            /// Execute the fetch request and store the results in a variable
            let fetchedResults = try managedObjectContext.fetch(fetchRequest)
            
            // Debug: Print the number of fetched results for the current mapID
            debugPrint("***** Debug: Number of fetched results for mapID \(self.selectedMapID ?? "None"): \(fetchedResults.count)")
            
            /// Initialize an empty array to hold PointAnnotation objects
            var pointAnnotations: [PointAnnotation] = []
            
            /// Initialize arrays to hold coordinates for different types of entries: Perimeter, Excluded, and Charging
            var perimeterCoordinates: [CLLocationCoordinate2D] = []
            var excludedCoordinates: [CLLocationCoordinate2D] = []
            var chargingCoordinates: [CLLocationCoordinate2D] = []
            
            /// Loop through the fetched results to create annotations
            for dataPoint in fetchedResults {
                debugPrint("***** Debug: Fetched Data - Latitude: \(dataPoint.latitude), Longitude: \(dataPoint.longitude), MapID: \(dataPoint.mapID ?? "None")")
                
                /// Create a coordinate using the latitude and longitude of each data point
                let coordinate = CLLocationCoordinate2DMake(dataPoint.latitude, dataPoint.longitude)
                
                /// Create a PointAnnotation object with the coordinate
                var pointAnnotation = PointAnnotation(coordinate: coordinate)
                
                /// Populate the userInfo dictionary with latitude, longitude, and Core Data objectID
                pointAnnotation.userInfo = ["latitude": dataPoint.latitude, "longitude": dataPoint.longitude, "objectID": dataPoint.objectID]
                
                /// Determine the image for the annotation based on the entryType
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
            
            /// Create PolylineAnnotations for different types: Perimeter, Excluded, and Charging
            var perimeterPolyline = PolylineAnnotation(lineCoordinates: perimeterCoordinates)
            perimeterPolyline.lineColor = StyleColor(.green)
            
            var excludedPolyline = PolylineAnnotation(lineCoordinates: excludedCoordinates)
            excludedPolyline.lineColor = StyleColor(.red)
            
            var chargingPolyline = PolylineAnnotation(lineCoordinates: chargingCoordinates)
            chargingPolyline.lineColor = StyleColor(.blue)
            
            /// Assign the array of PointAnnotations to the manager
            pointAnnotationManager?.annotations = pointAnnotations
            
            /// Assign the PolylineAnnotations to the PolylineAnnotationManager
            polylineAnnotationManager?.annotations = [perimeterPolyline, excludedPolyline, chargingPolyline]
            
        } catch {
            /// Print any errors that occur during fetching
            debugPrint("Failed to fetch GPS data points: \(error)")
        }
    }
    
    
    // MARK: - View Lifecycle Methods
    /// Function that runs when the view loads.
    /// It initializes the Mapbox map, location manager, and other UI elements.
    override public func viewDidLoad() {
        super.viewDidLoad()
        debugPrint("***** Debug: selectedMapID in viewDidLoad \(self.selectedMapID ?? "None")")
        
        // Retrieve the last selected map ID if available
        if let lastSelectedMapID = UserDefaults.standard.string(forKey: "lastSelectedMapID") {
            selectedMapID = lastSelectedMapID
        } else {
            // Set a default mapID if one hasn't been set yet
            if selectedMapID == nil {
                selectedMapID = " "  // Replace "FirstMap" with your actual default map ID
            }
        }
        
        
        // Initialize UI and Managers
        initializeLocationManager()
        initializeMapView()
        
        // Initialize Annotation Managers
        pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
        polylineAnnotationManager = mapView.annotations.makePolylineAnnotationManager()
        
        // Add zoom buttons
        //addZoomButtons()
        
        // New: Fetch unique mapIDs from Core Data
        fetchUniqueMapIDs()
        
        // Sort the mapIDs to ensure a predictable order
        mapIDs.sort()
        
        // New: Initialize Picker View
        initializePickerView()
        
        // Set a default mapID if one hasn't been set yet
        if selectedMapID == nil {
            selectedMapID = "Pick a Map"
        }
        
        // Fetch and annotate GPS data points
        //fetchAndAnnotateGPSData()
    }
    
    
    /// Initializes the Location Manager and requests user authorization for location access.
    func initializeLocationManager() {
        debugPrint("***** initializeLocationManager called")
        locationManager = CLLocationManager()  // Initialize CLLocationManager
        locationManager.delegate = self  // Set the delegate to self
        locationManager.requestWhenInUseAuthorization()  // Request permission to access location
    }
    
    /// Initializes the Mapbox MapView and adds it to the view hierarchy.
    func initializeMapView() {
        debugPrint("***** initializeMapView called")
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
    
    // MARK: - Fetch Unique Map IDs
    /**
     Fetches unique map IDs from the Core Data model and updates the mapIDs array.
     Ensures "Pick A Map" is the first element in the mapIDs array.
     
     - Parameters: None
     - Returns: None
     */
    func fetchUniqueMapIDs() {
        // Debug print statement to indicate that the function has been called
        debugPrint("***** fetchUniqueMapIDs called")
        
        // Initialize an empty set to hold unique mapIDs
        var uniqueMapIDsSet = Set<String>()
        
        // Create a fetch request for the GPSDataPoint entity in Core Data
        let fetchRequest: NSFetchRequest<GPSDataPoint> = GPSDataPoint.fetchRequest()
        
        do {
            // Execute the fetch request and store the results in a variable
            let fetchedResults = try managedObjectContext.fetch(fetchRequest)
            
            // Loop through the fetched results to collect unique mapIDs
            for dataPoint in fetchedResults {
                if let mapID = dataPoint.mapID {
                    uniqueMapIDsSet.insert(mapID)
                }
            }
            
            // Convert the set to an array and sort it
            mapIDs = Array(uniqueMapIDsSet).sorted()
            
            // Custom sort to ensure "Pick A Map" is the first item
            mapIDs.sort { (a, b) -> Bool in
                if a == "Pick A Map" {
                    return true
                }
                if b == "Pick A Map" {
                    return false
                }
                return a < b
            }
            
            // Debug print statement to show the new sorted content of mapIDs
            debugPrint("***** Debug: New sorted mapIDs content: \(mapIDs)")
            
        } catch {
            // Handle any errors that occur during fetching
            debugPrint("***** Failed to fetch GPS data points: \(error)")
        }
    }
    
    // MARK: - Update and Broadcast Selected Map ID
    /**
     Updates the selected map ID and broadcasts the change.
     Includes a debug print statement to check the new selected map ID.
     
     - Parameters:
     - newMapID: The new map ID to be set
     - Returns: None
     */
    func updateSelectedMapID(newMapID: String) {
        if newMapID == "Pick A Map" {
            // Clearing annotations and polylines when "Pick A Map" is selected
            self.selectedMapID = nil
            UserDefaults.standard.removeObject(forKey: "lastSelectedMapID")
            pointAnnotationManager?.annotations = []
            polylineAnnotationManager?.annotations = []
            mapIDs = ["Pick A Map"]
            debugPrint("***** Debug: Cleared all annotations and polylines")  // Debug statement
        } else {
            self.selectedMapID = newMapID
            // Save the newly selected map ID for future app launches
            UserDefaults.standard.set(newMapID, forKey: "lastSelectedMapID")
            
            debugPrint("***** Debug: Updated selectedMapID to \(newMapID)")  // Debug statement
            
            NotificationCenter.default.post(name: Notification.Name("selectedMapIDChanged"), object:nil, userInfo: ["selectedMapID": newMapID])
            
            // Explicitly fetch and annotate GPS data for the new selectedMapID
            fetchAndAnnotateGPSData()
        }
    }
    
    
    // MARK: - Handle Selected Map ID Change
    /**
     Handles the change in selected map ID and updates the annotations.
     
     - Parameters:
     - notification: The notification object containing the new map ID
     - Returns: None
     */
    @objc func handleSelectedMapIDChange(_ notification: Notification) {
        debugPrint("***** Debug: handleSelectedMapIDChange triggered")  // Debug statement
        if let userInfo = notification.userInfo, let newMapID = userInfo["selectedMapID"] as? String {
            debugPrint("***** Debug: New selectedMapID from notification is \(newMapID)")  // Debug statement
            self.selectedMapID = newMapID
            fetchAndAnnotateGPSData()
        }
    }
    
    // MARK: - Debug Control
    /// Variable to control debug printing. Set to true to enable debug prints and false to disable them.
    /// Custom debug print function.
    func debugPrint(_ items: Any...) {
        if debugMode {
            print(items)
        }
    }
    
    // MARK: - Initialize Picker View
    /**
     Initializes the Picker view for selecting a map ID and adds it to the view hierarchy.
     
     The function initializes a SwiftUI Picker view using the MapIDPicker struct.
     It then wraps this SwiftUI view into a UIHostingController to be compatible with UIKit.
     The picker allows users to select a map ID, which is then used to fetch and display
     corresponding GPS data points as annotations on the Mapbox map.
     
     - Parameters: None
     - Returns: None
     */
    func initializePickerView() {
        debugPrint("***** initializePickerView called")  // Debug statement
        
        // Make sure "Pick A Map" is the first element
        if !mapIDs.contains("Pick A Map") {
            mapIDs.insert("Pick A Map", at: 0)
        }
        
        // Initialize MapIDPicker SwiftUI View
        // The picker is initialized with the current list of map IDs and a callback function to update the selected map ID.
        let picker = MapIDPicker(mapIDs: self.mapIDs) { selectedMapID in
            self.updateSelectedMapID(newMapID: selectedMapID)
        }
        
        // Create a UIHostingController to host the SwiftUI Picker view
        // This allows us to add the SwiftUI view to our UIKit-based view hierarchy.
        self.pickerHostingController = UIHostingController(rootView: picker)
        
        // Configure the appearance and layout of the hosting controller's view
        if let pickerHC = self.pickerHostingController {
            pickerHC.view.translatesAutoresizingMaskIntoConstraints = false
            pickerHC.view.backgroundColor = .clear  // Set the background color to clear
            
            // Add the hosting controller as a child view controller
            // This ensures that it participates in the UIKit view controller lifecycle.
            self.addChild(pickerHC)
            self.view.addSubview(pickerHC.view)
            pickerHC.didMove(toParent: self)
            
            // Add layout constraints to position the picker view
            // The picker is positioned 20 points from the leading and trailing edges and 20 points from the top safe area.
            NSLayoutConstraint.activate([
                pickerHC.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
                pickerHC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
                pickerHC.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
                pickerHC.view.heightAnchor.constraint(equalToConstant: 50)  // Set the height of the picker view to 50 points
            ])
        }
    }
    
    
    
    // MARK: - UI Customization Methods
    /// Contains methods for customizing the UI, such as adding zoom buttons.
    
    /// Function to add zoom buttons to the map.
    // MARK: - MapZoomDelegate Protocol Methods
    /// Implementation for the zoomIn function from the MapZoomDelegate protocol
    ///
    /// This function handles zooming in on the Mapbox map.
    func zoomIn() {
        var zoom = mapView.cameraState.zoom
        zoom += 1.0 // Increment the zoom level by 1. Adjust as needed.
        let cameraOptions = CameraOptions(zoom: zoom)
      //  mapView.setCamera(to: cameraOptions)
        mapView.mapboxMap.setCamera(to: CameraOptions(zoom: mapView.mapboxMap.cameraState.zoom + 1))
        debugPrint("zoomIn Triggered")
    }
    
    /// Implementation for the zoomOut function from the MapZoomDelegate protocol
    ///
    /// This function handles zooming out on the Mapbox map.
    func zoomOut() {
        var zoom = mapView.cameraState.zoom
        zoom -= 1.0 // Decrement the zoom level by 1. Adjust as needed.
        let cameraOptions = CameraOptions(zoom: zoom)
        mapView.mapboxMap.setCamera(to: CameraOptions(zoom: mapView.mapboxMap.cameraState.zoom - 1))
        debugPrint("zoomOut Triggered")
    }
}
