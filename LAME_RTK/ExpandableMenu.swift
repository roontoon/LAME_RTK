//
//  ExpandableMenu.swift
//  LAME_RTK
//
//  Created by Roontoon on 10/12/23.
//  Last Modified on: 10/27/23
//
//  Overview:
//  This version includes an explicit width for the expanded menu,
//  bold SF Symbols, and a spring animation for the expandable menu.
//

// MARK: - Import Statements
import SwiftUI

// MARK: - Main ExpandableMenu View
/// Main view that hosts the expandable menu.
struct ExpandableMenu: View {
    
    // MARK: - State Variables
    /// Controls the state of the menu (expanded or not).
    @State private var isExpanded = false
    /// State variable for the picker selection.
    @State private var pickerSelection = "Option 1"
    
    // MARK: - View Body
    /// The body property defines the structure and content of the view.
    var body: some View {
        
        // Root ZStack to overlay content
        ZStack {
            
            // MARK: - Expanded Menu (Left to Right)
            if isExpanded {
                HStack {
                    // Picker at the far left
                    Picker("Options", selection: $pickerSelection) {
                        Text("Option 1").tag("Option 1").foregroundColor(.white)
                        Text("Option 2").tag("Option 2").foregroundColor(.white)
                        Text("Option 3").tag("Option 3").foregroundColor(.white)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Icon buttons with white foreground
                    createIconButton("star.fill")
                    Spacer()
                    createIconButton("pencil")
                    Spacer()
                    createIconButton("trash")
                    Spacer()
                    createIconButton("folder")
                    Spacer()
                    
                    // Map Icon on the far right-hand side
                    Image(systemName: "map")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .bold))  // Bold SF Symbol
                        .padding(10)
                        .background(Color(white: 0.8))
                        .clipShape(Circle())
                        .offset(x: 12)  // Precise X control
                }
                .padding(.horizontal, 10)
                .frame(width: 369, height: 44)  // Explicit Frame
                .background(RoundedRectangle(cornerRadius: 44)
                .fill(Color(white: 0.8)))
                .onTapGesture {
                    isExpanded.toggle()  // Toggle expand state
                }
                .animation(.spring())  // Spring animation
            }
            
            // MARK: - Map Circle Button (Right Bottom)
            if !isExpanded {
                HStack {
                    Spacer()  // Align to the right
                    Button(action: {
                        isExpanded.toggle()  // Toggle expand state
                    }) {
                        Image(systemName: "map")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .bold))  // Bold SF Symbol
                            .padding(10)
                            .background(Color(white: 0.8))
                            .clipShape(Circle())
                    }
                    .padding(10)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    /// Creates an icon button with a given system image name.
    ///
    /// - Parameters:
    ///   - systemName: The name of the system image to be used.
    /// - Returns: A Button view with the specified system image.
    func createIconButton(_ systemName: String) -> some View {
        Button(action: {
            // Action for each button
        }) {
            Image(systemName: systemName)
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .bold))  // Bold SF Symbol
        }
    }
}

// MARK: - ExpandableMenu Preview
/// Provides a preview of the ExpandableMenu view.
struct ExpandableMenu_Previews: PreviewProvider {
    static var previews: some View {
        ExpandableMenu()
    }
}
