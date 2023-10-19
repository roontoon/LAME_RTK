
/// MapIDPickerBody.swift
/// Date and Time Documented: October 17, 2023, 12:30 PM
///
/// This file defines the body of the MapIDPicker SwiftUI view.
/// It contains the UI elements that make up the Picker, as well as behavior for selection changes.

import SwiftUI

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
                        //.backgroundColor(.red)  // Set the font color to red
                }
            }
            .onChange(of: selectedMapID, perform: onSelectionChanged)  // Use .onChange to handle selection changes
            .onAppear() {
                debugPrint("***** Rendering Picker with selectedMapID: \(selectedMapID)")
            }
            Spacer()
            Text("right")
            Spacer()
            Text("left")
            Spacer()
            
        }
        .padding(0)  // Zero padding on top and bottom
        .background(Color(UIColor.systemGray4))
        .overlay(
            RoundedRectangle(cornerRadius: 8) // You can adjust the corner radius
                .stroke(Color.black, lineWidth: 1)  // Set the stroke color to black and line width to 2
        )
    }
}
