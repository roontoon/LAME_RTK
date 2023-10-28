//
//  ExpandableMenu.swift
//  LAME_RTK
//
//  Created by Roontoon on 10/12/23.
//  Last Modified on: 10/27/23
//
//  Overview:
//  This SwiftUI View file defines the ExpandableMenu view.
//  The ExpandableMenu starts as a circle with an SFImage "map", located at the far right bottom.
//  When clicked, it expands to the full open position with a green fill in between.
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
            
            // Your other content can go here
            
            // MARK: - Expanded Menu (Left to Right)
            if isExpanded {
                HStack {
                    
                    RoundedRectangle(cornerRadius: 39)
                        .fill(Color(white: 0.8))
                        .frame(width: 370, height: 39)
                    
                }
                .padding(10)  // Padding adjusted to 10
                .onTapGesture {
                    isExpanded.toggle()  // Toggle expand state
                }
            }
            
            // MARK: - Map Circle Button (Right Bottom)
            // This button is now declared after the expanded menu to ensure it is rendered above.
            Button(action: {
                isExpanded.toggle()  // Toggle expand state
            }) {
                HStack{ Spacer()
                    ZStack{
                        Image(systemName: "map")
                            .foregroundColor(isExpanded ? .white : .white) // Foreground color changes based on expand state
                            .padding(10)  // Padding adjusted to 10
                            .background(Color(white: 0.8))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(10)  // Padding adjusted to 10
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
