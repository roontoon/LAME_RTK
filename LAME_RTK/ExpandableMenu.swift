//
//  ExpandableMenu.swift
//  LAME_RTK
//
//  Created by Roontoon on 10/12/23.
//  Last Modified on: 10/27/23
//
//  Overview:
//  This SwiftUI View file defines the ExpandableMenu view.
//  The ExpandableMenu starts as a light green/gray circle with an SFImage "map", located at the far right bottom.
//  When clicked, it expands to the full open position, which is circular on both ends with a green fill in between.
//

import SwiftUI

// MARK: - Main ExpandableMenu View
/// Main view that hosts the expandable menu.
struct ExpandableMenu: View {
    
    // MARK: - State Variables
    /// Controls the state of the menu (expanded or not).
    @State private var isExpanded = false
    
    // MARK: - View Body
    /// The body property defines the structure and content of the view.
    var body: some View {
        
        // Root ZStack to overlay content
        ZStack(alignment: .bottomTrailing) {
            Spacer()
            
            // MARK: - Expanded Menu (Right to Left)
            /// When the menu is expanded, this rounded rectangle with green fill appears.
            if isExpanded {
                HStack {
                    
                    Spacer()
                    RoundedRectangle(cornerRadius: 39)
                        .fill(Color.green.opacity(0.5))
                        .frame(width: 340, height: 39)
                    Spacer()
                }
                .padding(10)  // Padding adjusted to 10
                .onTapGesture {
                    isExpanded.toggle()  // Toggle expand state
                }
            }
            
            // MARK: - Map Circle Button (Right Bottom)
            /// When the menu is not expanded, this button appears at the bottom right.
            /// Clicking this button toggles the expanded state.
            if !isExpanded || isExpanded {
                Button(action: {
                    isExpanded.toggle()  // Toggle expand state
                }) {
                    
                    ZStack{
                        HStack{
                            Spacer()
                            Image(systemName: "map")
                                .foregroundColor(isExpanded ? .red : .white)  // Foreground color changes based on expanded state
                                .padding(10)  // Padding adjusted to 10
                                .background(Color.green.opacity(0.5))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(10)  // Padding adjusted to 10
            }
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
