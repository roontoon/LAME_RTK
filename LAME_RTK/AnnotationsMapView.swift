/// AnnotationsMapView.swift
/// Date and Time Documented: October 9, 2023, 3:00 PM
///
/// This file defines a SwiftUI view and a UIViewController that handles the Mapbox map annotations.
/// It fetches GPS data points from Core Data, displays them as annotations on the map,
/// allows users to edit latitude and longitude directly in the annotation's popup window,
/// and refreshes the map after editing.

// Import the necessary modules for UI, Mapbox, Core Data, and Core Location
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
        // Note: This function is left intentionally empty for now
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
    
    /// Declare a variable to manage Point Annotations
    var pointAnnotationManager: PointAnnotationManager?

    /// Declare a variable to manage Polyline Annotations
    var polylineAnnotationManager: PolylineAnnotationManager?
    
    /// Declare a variable for the location manager
    var locationManager: CLLocationManager!
    
    /// Declare a variable to check if the map has been centered
    var hasCenteredMap = false

    /// Declare a variable to o store unique mapIDs
    //var uniqueMapIDs: [String] = []
    
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
        print("Tapped on annotation: \(annotations)") // Debug print
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
        print("***** updateGPSDataPoint called")
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

    // MARK: - MapIDPicker SwiftUI View
    struct MapIDPicker: View {
        var mapIDs: [String]
        @State var selectedMapID: String = "Pick a Map" // Track the currently selected map ID
        var onMapIDSelected: (String) -> Void

        var body: some View {
            Picker("Select Map ID", selection: $selectedMapID) {
                Text("Pick a Map").tag("Pick a Map")
                ForEach(mapIDs, id: \.self) { mapID in
                    Text(mapID).tag(mapID)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onReceive([self.selectedMapID].publisher.first()) { (newMapID) in
                onMapIDSelected(newMapID)
            }
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
        
        // Debugging statement to print the mapID for which data is being fetched
        print("***** fetchAndAnnotateGPSData called for mapID: \(self.selectedMapID ?? "None")")
        
        /// Create a fetch request for the GPSDataPoint entity in Core Data
        let fetchRequest: NSFetchRequest<GPSDataPoint> = GPSDataPoint.fetchRequest()
        
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
            print("***** Debug: Number of fetched results for mapID \(self.selectedMapID ?? "None"): \(fetchedResults.count)")
            
            /// Initialize an empty array to hold PointAnnotation objects
            var pointAnnotations: [PointAnnotation] = []
            
            /// Initialize arrays to hold coordinates for different types of entries: Perimeter, Excluded, and Charging
            var perimeterCoordinates: [CLLocationCoordinate2D] = []
            var excludedCoordinates: [CLLocationCoordinate2D] = []
            var chargingCoordinates: [CLLocationCoordinate2D] = []
            
            /// Loop through the fetched results to create annotations
            for dataPoint in fetchedResults {
                print("***** Debug: Fetched Data - Latitude: \(dataPoint.latitude), Longitude: \(dataPoint.longitude), MapID: \(dataPoint.mapID ?? "None")")
                
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
            print("Failed to fetch GPS data points: \(error)")
        }
    }


    // MARK: - View Lifecycle Methods
    /// Function that runs when the view loads.
    /// It initializes the Mapbox map, location manager, and other UI elements.
    override public func viewDidLoad() {
        super.viewDidLoad()
        print("***** Debug: selectedMapID in viewDidLoad \(self.selectedMapID ?? "None")")
        
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
        addZoomButtons()

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
        fetchAndAnnotateGPSData()
    }
    
 
    /// Initializes the Location Manager and requests user authorization for location access.
    func initializeLocationManager() {
        print("***** initializeLocationManager called")
        locationManager = CLLocationManager()  // Initialize CLLocationManager
        locationManager.delegate = self  // Set the delegate to self
        locationManager.requestWhenInUseAuthorization()  // Request permission to access location
    }

    /// Initializes the Mapbox MapView and adds it to the view hierarchy.
    func initializeMapView() {
        print("***** initializeMapView called")
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

    // MARK: - Initialize SwiftUI Picker
        /**
         Initializes the SwiftUI Picker and adds it to the view hierarchy.

         - Parameters: None
         - Returns: None
        */
    func initializePickerView() {
        print("***** initializePickerView called")
        
        // Debug: Log the content of mapIDs
        print("***** Debug: mapIDs content: \(mapIDs)")
        
        let picker = MapIDPicker(mapIDs: mapIDs) { [self] selectedMapID in
            print("***** Picker selected: \(selectedMapID)")  // Debugging statement
            self.updateSelectedMapID(newMapID: selectedMapID)
        }
        
        pickerHostingController = UIHostingController(rootView: picker)
        pickerHostingController?.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Debug: Check if pickerHostingController's view is nil
        if pickerHostingController?.view == nil {
            print("***** Debug: pickerHostingController's view is nil")
        } else {
            print("***** Debug: pickerHostingController's view is not nil")
        }
        
        addChild(pickerHostingController!)
        view.addSubview(pickerHostingController!.view)
        
        let constraints = [
            pickerHostingController!.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            pickerHostingController!.view.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            pickerHostingController!.view.widthAnchor.constraint(equalToConstant: 200),
            pickerHostingController!.view.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        pickerHostingController?.didMove(toParent: self)
        
        // Debug: Log the frame after applying constraints
        DispatchQueue.main.async {
            print("***** Debug: pickerHostingController's view frame after constraints: \(String(describing: self.pickerHostingController?.view.frame))")
        }
    }

    
 /*  // MARK: - Update and Broadcast Selected Map ID
    /**
     Updates the selected map ID and broadcasts the change.
     Includes a debug print statement to check the new selected map ID.

     - Parameters:
        - newMapID: The new map ID to be set
     - Returns: None
    */
    func updateSelectedMapID(newMapID: String) {
        self.selectedMapID = newMapID
        print("***** Debug: Updated selectedMapID to \(newMapID)")  // Debug statement
        NotificationCenter.default.post(name: Notification.Name("selectedMapIDChanged"), object: nil, userInfo: ["selectedMapID": newMapID])
    }
    */
    // MARK: - Fetch Unique Map IDs
    /**
     Fetches unique map IDs from the Core Data model and updates the mapIDs array.

     This function fetches all unique `mapID` values from the `GPSDataPoint` entity in Core Data.
     It then updates the `mapIDs` array to reflect these values.

     - Parameters: None
     - Returns: None
     */
    func fetchUniqueMapIDs() {
        print("***** fetchUniqueMapIDs called")
        
        // Initialize an empty set to hold unique mapIDs
        var uniqueMapIDsSet = Set<String>()
        
        // Create a fetch request for the GPSDataPoint entity in Core Data
        let fetchRequest: NSFetchRequest<GPSDataPoint> = GPSDataPoint.fetchRequest()
        
        do {
            // Execute the fetch request and store the results in a variable
            let fetchedResults = try managedObjectContext.fetch(fetchRequest)
            
            // Debug: Log the count of fetched results
            print("***** Debug: Number of fetched results: \(fetchedResults.count)")
            
            // Loop through the fetched results to collect unique mapIDs
            for dataPoint in fetchedResults {
                if let mapID = dataPoint.mapID {
                    uniqueMapIDsSet.insert(mapID)
                }
            }
            
            // Convert the set to an array
            mapIDs = Array(uniqueMapIDsSet)
            
            // Sort the fetched map IDs
            mapIDs.sort()

             print("***** Debug: New mapIDs content: \(mapIDs)")
                        
        } catch {
            // Handle any errors that occur during fetching
            print("***** Failed to fetch GPS data points: \(error)")
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
    /*func updateSelectedMapID(newMapID: String) {
        // Check if the "Pick a Map" option is selected
        if newMapID != "Pick a Map" {
            self.selectedMapID = newMapID
            print("***** Debug: Updated selectedMapID to \(newMapID)")  // Debug statement
            NotificationCenter.default.post(name: Notification.Name("selectedMapIDChanged"), object: nil, userInfo: ["selectedMapID": newMapID])
            
            // Explicitly fetch and annotate GPS data for the new selectedMapID
            fetchAndAnnotateGPSData()
        }
    }*/
    
    func updateSelectedMapID(newMapID: String) {
        // Check if the "Pick a Map" option is selected
        if newMapID != "Pick a Map" {
            self.selectedMapID = newMapID
            // Save the newly selected map ID for future app launches
            UserDefaults.standard.set(newMapID, forKey: "lastSelectedMapID")

            print("***** Debug: Updated selectedMapID to \(newMapID)")  // Debug statement
            
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
        print("***** Debug: handleSelectedMapIDChange triggered")  // Debug statement
        if let userInfo = notification.userInfo, let newMapID = userInfo["selectedMapID"] as? String {
            print("***** Debug: New selectedMapID from notification is \(newMapID)")  // Debug statement
            self.selectedMapID = newMapID
            fetchAndAnnotateGPSData()
        }
    }


    // MARK: - UI Customization Methods
    /// Contains methods for customizing the UI, such as adding zoom buttons.
    
    /// Function to add zoom buttons to the map.
    @objc func addZoomButtons() {
        print("***** addZoomButtons called")

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
