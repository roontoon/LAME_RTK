//
//  MapIDPickerBody.swift
//  YourApp
//
//  Created by Your Name on Date
//  Date and Time Documented: October 17, 2023, 12:30 PM
//
//  Overview:
//  This file defines the body of the MapIDPicker SwiftUI view.
//  It contains the UI elements that make up the Picker, as well as behavior for selection changes.
//  The body also contains zoom-in and zoom-out buttons that delegate their actions to an external object.
//

import SwiftUI

// MARK: - MapZoomDelegate Protocol
/// Protocol to delegate zooming actions to an external object.
protocol MapZoomDelegate: AnyObject {
    /// Function to handle zooming in on the map.
    func zoomIn()
    
    /// Function to handle zooming out on the map.
    func zoomOut()
}

// MARK: - MapIDPicker
struct MapIDPicker {
    
    // MARK: - Properties
    /// An array of map IDs to display in the picker.
    let mapIDs: [String]
    
    /// A binding to the currently selected map ID.
    @Binding var selectedMapID: String
    
    /// Declare a variable to hold the delegate instance
    private var delegate: MapZoomDelegate?

    // MARK: - Setting the Delegate
    /// Function to set the delegate for map zooming actions.
    ///
    /// - Parameters:
    ///   - newDelegate: An object that conforms to the MapZoomDelegate protocol.
    mutating func setZoomDelegate(newDelegate: MapZoomDelegate) {
        self.delegate = newDelegate
    }
    
    // MARK: - Body Definition
    /// The body of the MapIDPicker.
    ///
    var body: some View {
        HStack {
            Spacer()
            Picker("Select Map ID", selection: $selectedMapID) {
                ForEach(mapIDs, id: \.self) { mapID in
                    Text(mapID)
                        .font(.custom("Arial", size: 8))
                }
            }
            .onChange(of: selectedMapID) { newValue in
                debugPrint("***** Rendering Picker with selectedMapID: \(newValue)")
            }
            Spacer()
            
            // MARK: - Zoom Buttons
            /// Zoom buttons for the map.
            HStack {
                // Zoom In Button
                Button(action: {
                    delegate?.zoomIn()
                }) {
                    Image(systemName: "plus.magnifyingglass")
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                // Zoom Out Button
                Button(action: {
                    delegate?.zoomOut()
                }) {
                    Image(systemName: "minus.magnifyingglass")
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.red)
                        .cornerRadius(8)
                }
            }
            Spacer()
        }
        .padding(0)
        .background(Color.gray)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black, lineWidth: 1)
        )
    }
}
