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
    internal var mapView: MapView!
    
    // Fetch the default latitude and longitude from AppStorage
    @AppStorage("defaultLongitude") var defaultLongitude: Double = 0.0
    @AppStorage("defaultLatitude") var defaultLatitude: Double = 0.0
    
    // Declare a variable to hold the managed object context from Core Data.
    let managedObjectContext = PersistenceController.shared.container.viewContext
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let myResourceOptions = ResourceOptions(accessToken: "sk.eyJ1Ijoicm9vbnRvb24iLCJhIjoiY2xtamZ1b3UzMDJ4MjJrbDgxMm0ya3prMiJ9.VtLaE_XUfS9QSXa2QREpdQ")
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: defaultLatitude, longitude: defaultLongitude), zoom: 19)
        let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions, cameraOptions: cameraOptions, styleURI: .streets)
        
        mapView = MapView(frame: view.bounds, mapInitOptions: myMapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(mapView)
        
        // Fetch and annotate GPS data points from Core Data.
        fetchAndAnnotateGPSData()
    }
    
    func fetchAndAnnotateGPSData() {
        let fetchRequest: NSFetchRequest<GPSDataPoint> = GPSDataPoint.fetchRequest()
        
        do {
            let fetchedResults = try managedObjectContext.fetch(fetchRequest)
            
            var pointAnnotations: [PointAnnotation] = []
            
            for dataPoint in fetchedResults {
                print("Latitude: \(dataPoint.latitude), Longitude: \(dataPoint.longitude)")
                
                var pointAnnotation = PointAnnotation(coordinate: CLLocationCoordinate2DMake(dataPoint.latitude, dataPoint.longitude))
                pointAnnotation.image = .init(image: UIImage(named: "GreenDiamond")!, name: "GreenDiamond")
                pointAnnotation.iconAnchor = .bottom
                
                pointAnnotations.append(pointAnnotation)
            }
            
            let pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
            pointAnnotationManager.annotations = pointAnnotations
            
        } catch {
            print("Failed to fetch GPS data points: \(error)")
        }
    }
}

