// Import UIKit for building user interface and Mapbox for map functionality
import SwiftUI
import MapboxMaps

struct LAMEMapView: UIViewControllerRepresentable {
     
    func makeUIViewController(context: Context) -> MapViewController {
           return MapViewController()
       }
      
    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
    }
}

class MapViewController: UIViewController {
   internal var mapView: MapView!
   override public func viewDidLoad() {
       super.viewDidLoad()
       
       let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 28.069767, longitude: -82.484428), zoom: 19, bearing: 0, pitch: 0)

       let myResourceOptions = ResourceOptions(accessToken: "sk.eyJ1Ijoicm9vbnRvb24iLCJhIjoiY2xtamZ1b3UzMDJ4MjJrbDgxMm0ya3prMiJ9.VtLaE_XUfS9QSXa2QREpdQ")

       let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions, cameraOptions: cameraOptions)
       
       mapView = MapView(frame: view.bounds, mapInitOptions: myMapInitOptions)
       
       mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
       
       self.view.addSubview(mapView)
   }
}
