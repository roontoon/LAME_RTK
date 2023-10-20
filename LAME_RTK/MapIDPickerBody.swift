/// MapIDPickerBody.swift
/// Date and Time Documented: October 17, 2023, 12:30 PM
///
/// This file defines the body of the MapIDPicker SwiftUI view.
/// It contains the UI elements that make up the Picker, as well as behavior for selection changes.
/// The body also contains zoom-in and zoom-out buttons that delegate their actions to an external object.

import SwiftUI
import MapboxMaps

// Declare a variable to hold the delegate instance
var delegate: MapZoomDelegate?

// MARK: - MapZoomDelegate Protocol
/// Protocol to delegate zooming actions to an external object.
protocol MapZoomDelegate: AnyObject {
    /// Function to handle zooming in on the map.
    func zoomIn()
    
    /// Function to handle zooming out on the map.
    func zoomOut()
}

extension MapIDPicker {
    
    
    // MARK: - Body Definition
    /// The body of the MapIDPicker.
    ///
    var body: some View {
        HStack{
            Spacer()
            Picker("Select Map ID", selection: $selectedMapID) {
                ForEach(mapIDs, id: \.self) { mapID in
                    Text(mapID)
                        .font(.custom("Arial", size: 8))  // Set the font to Arial with a size of 14
                }
            }
            .onChange(of: selectedMapID, perform: onSelectionChanged)  // Use .onChange to handle selection changes
            .onAppear() {
                debugPrint("***** Rendering Picker with selectedMapID: \(selectedMapID)")
            }
            Spacer()
            
            // MARK: - Zoom Buttons
            HStack {
                // Zoom In Button
                Button(action: {
                    // Delegate the zoomIn action to the external object.
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
                    // Delegate the zoomOut action to the external object.
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
        .padding(0)  // Zero padding on top and bottom
        .background(Color(UIColor.systemGray4))
        .overlay(
            RoundedRectangle(cornerRadius: 8) // You can adjust the corner radius
                .stroke(Color.black, lineWidth: 1)  // Set the stroke color to black and line width to 1
        )
    }
    // MARK: - Setting the Delegate
    /// Function to set the delegate for map zooming actions.
    ///
    /// - Parameters:
    ///   - newDelegate: An object that conforms to the MapZoomDelegate protocol.
    func setZoomDelegate(newDelegate: MapZoomDelegate) {
        delegate = newDelegate
    }
}
