//
//  PreferencesView.swift
//  Lame_RTK
//
//  Created by Roontoon on 9/5/23.
//  Date and Time Documented: October 23, 2023, 12:30 PM
//
//  Overview:
//  The PreferencesView struct defines the UI and behavior for the Preferences screen in the application.
//  It now also allows users to set the zoom level for the map.
//

import SwiftUI
import CoreLocation

// Create an observable class that holds the zoom level
class ZoomLevel: ObservableObject {
    @Published var level: Double = 19.0
}

// MARK: - PreferencesView Definition
struct PreferencesView: View {
    
    // MARK: - Variables and AppStorage
    @AppStorage("mowerWidth") var mowerWidth: Double = 0
    @AppStorage("laneOverlap") var laneOverlap: Double = 0
    @AppStorage("defaultLongitude") var defaultLongitude: Double = 0.0
    @AppStorage("defaultLatitude") var defaultLatitude: Double = 0.0
    
    // Store the zoom level setting, default is 19.
    @AppStorage("zoomLevel") var zoomLevel: Double = 19.0
    
    @State private var address: String = ""
    
    
    // MARK: - Main Body
    var body: some View {
        VStack {
            
            // Title
            Text("Preferences")
                .font(.title)
            
            // MARK: - Mower Width Slider
            HStack {
                Text("Mower Width (mm): \(Int(mowerWidth))")
                Slider(value: $mowerWidth, in: 0...600)
            }
            .padding()
            
            // MARK: - Lane Overlap Slider
            HStack {
                Text("Lane Overlap (mm): \(Int(laneOverlap))")
                Slider(value: $laneOverlap, in: 0...600)
            }
            .padding()
            
            // MARK: - Zoom Level Slider
            // Slider and label for adjusting the zoom level of the map.
            HStack {
                Text("Zoom Level: \(Int(zoomLevel))")
                Slider(value: $zoomLevel, in: 0...22)
                
            }
            .padding()
            
            // MARK: - Address Lookup
            TextField("Enter Address", text: $address)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Lookup Address") {
                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(address) { (placemarks, error) in
                    guard error == nil else {
                        print("Geocoding error: \(error!.localizedDescription)")
                        return
                    }
                    
                    if let firstPlacemark = placemarks?[0],
                       let location = firstPlacemark.location {
                        defaultLongitude = location.coordinate.longitude
                        defaultLatitude = location.coordinate.latitude
                    }
                }
            }
            .padding()
            
            // MARK: - Display Saved Location
            Text("Saved Longitude: \(defaultLongitude, specifier: "%.7f")")
            Text("Saved Latitude: \(defaultLatitude, specifier: "%.7f")")
        }
    }
}
