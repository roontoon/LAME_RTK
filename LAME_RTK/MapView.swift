//  Lame_RTK
//
//  Created by Roontoon on 9/5/23.
//\

import SwiftUI
import MapboxMaps

struct CustomMapView: UIViewRepresentable {
    var mapID: String = "TestData"  // Hardcoded for now, can be dynamic in the future
    
    // Coordinates from Preferences (hardcoded for now)
    let centerCoordinate = CLLocationCoordinate2D(latitude: 28.06993, longitude: -82.48436)
    
    func makeUIView(context: Context) -> MapboxMaps.MapView {
        let resourceOptions = ResourceOptions(accessToken: "pk.eyJ1Ijoicm9vbnRvb24iLCJhIjoiY2xtYmVwbjZ0MGtoczNpcDhkODBuazhiZCJ9.78F64JWyIb3kwNGxC4QwLQ")
        let mapInitOptions = MapInitOptions(resourceOptions: resourceOptions)
        let mapView = MapboxMaps.MapView(frame: context.coordinator.view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Center the map on the coordinates from Preferences and zoom to street level
        let cameraOptions = CameraOptions(center: centerCoordinate, zoom: 19.0)  // 15 is typically street-level zoom
        mapView.mapboxMap.setCamera(to: cameraOptions)
        
        return mapView
    }

    func updateUIView(_ uiView: MapboxMaps.MapView, context: Context) {
        // TODO: Add Mapbox-specific code for annotations and overlays
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject {
        var control: CustomMapView
        var view: UIView

        init(_ control: CustomMapView) {
            self.control = control
            self.view = UIView()
        }

        // TODO: Add Mapbox-specific code for annotations and overlays
    }
}

struct CustomMapView_Previews: PreviewProvider {
    static var previews: some View {
        CustomMapView()
    }
}
