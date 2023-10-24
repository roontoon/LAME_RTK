// -----------------------------------------------------------
// File: ContentView.swift
// Created: 2023-10-16
// Updated: 2023-10-17
// Overview:
// This file defines the main tab-based layout for the application.
// It includes tabs for GPS Data, JoyStick, MapView, Preferences, and Test.
// -----------------------------------------------------------

// MARK: - Import Modules

// Import necessary modules
import SwiftUI
import CoreLocation  // For CLLocationCoordinate2D

// MARK: - ContentView Structure

/// ContentView struct conforming to the View protocol
/// The main View for the application which contains tabs for different functionalities.
struct ContentView: View {
    
    // MARK: - Properties
    
    // Using Environment to fetch the managedObjectContext
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    // Fetch default latitude and longitude from AppStorage
    @AppStorage("defaultLongitude") var defaultLongitude: Double = 0.0
    @AppStorage("defaultLatitude") var defaultLatitude: Double = 0.0
    
    // State variable for selected map
    @State private var selectedMap = "map1"
    
    // MARK: - Body of ContentView
    
    /// The body property for the ContentView
    /// It contains the main layout of the application.
    var body: some View {
        
        // MARK: - Tab View Layout
        
        // Using TabView to create a tab-based layout
        TabView {
            
            // MARK: - Tab 1: GPSDataView
            
            // Tab for GPS Data
            GPSDataView()
                .tabItem {
                    Image(systemName: "1.circle.fill")  // Tab icon
                    Text("GPS Data")  // Tab title
                }
            
            // MARK: - Tab 2: JoyStickView
            
            // Tab for JoyStick
            JoyStickView()
                .tabItem {
                    Image(systemName: "2.circle.fill")  // Tab icon
                    Text("JoyStick")  // Tab title
                }
            
            // MARK: - Tab 3: FloatingMenu
            
            // Tab for MapView
            //FloatingMenu()
            SimplePickerView()
                .tabItem {
                    Image(systemName: "3.circle.fill")  // Tab icon
                    Text("MapView")  // Tab title
                }
            
            // MARK: - Tab 4: PreferencesView
            
            // Tab for Preferences
            PreferencesView()
                .tabItem {
                    Image(systemName: "4.circle.fill")  // Tab icon
                    Text("Pref")  // Tab title
                }
            
            // MARK: - Tab 5: AnnotationsMapView
            
            // Initialize AnnotationsMapView
            AnnotationsMapView()
                .tabItem {
                    Image(systemName: "5.circle.fill")  // Tab icon
                    Text("Test")  // Tab title
                }
           /* ///.onAppear {
            /// Debugging: Check if ContentView is appearing
            /// print("***** Debugging: ContentView for AnnotationsMapView did appear.")
            ///}
            */
        }
    }
}

// MARK: - Preview of ContentView

/// Preview for ContentView
/// This section provides a preview of the ContentView.
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()  // Previewing the ContentView
    }
}
