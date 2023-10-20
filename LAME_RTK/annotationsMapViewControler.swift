///
///  annotationsMapViewControler.swift
///  LAME_RTK
///
/// Created by Roontoon on 10/19/23.
///
/// AnnotationsMapViewController.swift
/// Date and Time Documented: October 19, 2023, 10:00 AM
///
/// This file defines a UIKit ViewController class named AnnotationsMapViewController.
/// This class is responsible for handling the Mapbox map, GPS annotations, and user interactions.
/// It initializes the Mapbox map, manages Point and Polyline annotations, and updates GPS data points.
///

// Import necessary modules
import MapboxMaps
import CoreLocation
import CoreData
import SwiftUI

// MARK: - SwiftUI View for AnnotationsMapViewController
/// Define a SwiftUI view that represents the AnnotationsMapViewController.
struct AnnotationsMapView: UIViewControllerRepresentable {
    
    // MARK: - UIViewControllerRepresentable Protocol Methods
    /// Create and return a new AnnotationsMapViewController when the view is made.
    ///
    /// - Parameters:
    ///   - context: A context structure that holds information relevant for this view.
    /// - Returns: An instance of AnnotationsMapViewController.
    func makeUIViewController(context: Context) -> AnnotationsMapViewController {
        return AnnotationsMapViewController()
    }
    
    /// Update the AnnotationsMapViewController when there are changes.
    ///
    /// - Parameters:
    ///   - uiViewController: The UI ViewController that this SwiftUI view wraps.
    ///   - context: A context structure that holds information relevant for this view.
    func updateUIViewController(_ uiViewController: AnnotationsMapViewController, context: Context) {
        // Note: This function is left intentionally empty for now
    }
}
