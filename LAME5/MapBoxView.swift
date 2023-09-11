//
//  MapBoxView.swift
//  Lame_RTK
//
//  Created by Roontoon on 9/8/23.
//

// Import SwiftUI for UI components and Mapbox for map functionalities
import SwiftUI
//import Mapbox

/*/ Define the MapBoxView struct conforming to UIViewRepresentable for integrating UIKit-based Mapbox into SwiftUI
struct MapBoxView: UIViewRepresentable {
    
    // Variable to identify the map, can be dynamic in the future
    var mapID: String = "TestData"
    
    // Function to create a Mapbox view (MGLMapView)
    func makeUIView(context: Context) -> MGLMapView {
        // Initialize a Mapbox map view with a satellite-streets style
        // This will be the initial setup when the map view is created
        let mapView = MGLMapView(frame: .zero, styleURL: MGLStyle.satelliteStreetsStyleURL)
        
        // Set the delegate to the coordinator for handling map events
        mapView.delegate = context.coordinator
        
        return mapView
    }

    // Function to update the Mapbox view when there are changes
    func updateUIView(_ uiView: MGLMapView, context: Context) {
        // Sample center coordinate for demonstration
        let centerCoordinate = CLLocationCoordinate2D(latitude: 28.06993, longitude: -82.48436)
        
        // Set the center coordinate and zoom level of the map
        // Zoom level 20 is used for maximum zoom
        uiView.setCenter(centerCoordinate, zoomLevel: 20, animated: true)
        
        // Existing code for annotations and overlays can be adapted for Mapbox
        // For demonstration, adding a single point annotation at the center coordinate
        let annotation = MGLPointAnnotation()
        annotation.coordinate = centerCoordinate
        annotation.title = "Perimeter"
        uiView.addAnnotation(annotation)
    }
    
    // Function to create a coordinator for handling map events
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Define the Coordinator class for handling map events
    final class Coordinator: NSObject, MGLMapViewDelegate {
        // Reference to the parent MapBoxView for accessing its properties and methods
        var control: MapBoxView

        // Initialize the coordinator with a reference to the parent MapBoxView
        init(_ control: MapBoxView) {
            self.control = control
        }

        // Implement Mapbox delegate methods for customizing map features
        // For demonstration, customizing the annotation view
        func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
            // Identifier for reusing annotation views
            let reuseIdentifier = "diamondPin"
            
            // Try to dequeue an existing annotation view first
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
            
            // If an annotation view isn’t available, create a new one
            if annotationView == nil {
                annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
            }
            
            // Customize the annotation view based on the annotation title
            // For demonstration, setting the background color to blue for "Perimeter"
            if let title = annotation.title, title == "Perimeter" {
                annotationView?.backgroundColor = .blue
            }
            
            return annotationView
        }
    }
}*/
