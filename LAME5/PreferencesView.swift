//
//  PreferencesView.swift
//  Lame_RTK
//
//  Created by Roontoon on 9/5/23.
//

import SwiftUI
import CoreLocation

// The PreferencesView struct defines the UI and behavior for the Preferences screen.
struct PreferencesView: View {
    
    // Using AppStorage to save and retrieve mowerWidth, laneOverlap, longitude, and latitude from UserDefaults.
    @AppStorage("mowerWidth") var mowerWidth: Double = 0
    @AppStorage("laneOverlap") var laneOverlap: Double = 0
    @AppStorage("defaultLongitude") var defaultLongitude: Double = 0.0
    @AppStorage("defaultLatitude") var defaultLatitude: Double = 0.0
    
    // State variable to hold the address entered by the user.
    @State private var address: String = ""
    
    // The body property defines the UI elements that make up the PreferencesView.
    var body: some View {
        VStack {
            
            // Title for the Preferences screen.
            Text("Preferences")
                .font(.title)
            
            // Slider and label for adjusting the mowerWidth.
            HStack {
                Text("Mower Width (mm): \(Int(mowerWidth))")
                
                // Slider for mowerWidth, ranging from 0 to 600 mm.
                Slider(value: $mowerWidth, in: 0...600)
            }
            .padding() // Adding padding for better layout.
            
            // Slider and label for adjusting the laneOverlap.
            HStack {
                Text("Lane Overlap (mm): \(Int(laneOverlap))")
                
                // Slider for laneOverlap, ranging from 0 to 600 mm.
                Slider(value: $laneOverlap, in: 0...600)
            }
            .padding() // Adding padding for better layout.
            
            // Text field for entering the address.
            TextField("Enter Address", text: $address)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // Button to perform the address lookup.
            Button("Lookup Address") {
                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(address) { (placemarks, error) in
                    guard error == nil else {
                        print("Geocoding error: \(error!.localizedDescription)")
                        return
                    }
                    
                    if let firstPlacemark = placemarks?[0],
                       let location = firstPlacemark.location {
                        // Save the longitude and latitude to UserDefaults.
                        defaultLongitude = location.coordinate.longitude
                        defaultLatitude = location.coordinate.latitude
                    }
                }
            }
            .padding() // Adding padding for better layout.
            
            // Display the saved longitude and latitude.
            Text("Saved Longitude: \(defaultLongitude, specifier: "%.8f")")
            Text("Saved Latitude: \(defaultLatitude, specifier: "%.8f")")
        }
    }
}
