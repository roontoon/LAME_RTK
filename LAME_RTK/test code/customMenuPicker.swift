//
//  CustomMenuPicker.swift
//  CustomMenuPickerExample
//
//  Created by Igor on 27/10/2023.
//  Last updated: 27/10/2023
//  This file contains a custom menu picker that allows changing the color of the first item when unselected.
//

import SwiftUI

// MARK: - Struct Definitions

/// A custom menu picker that allows changing the color of the first item when unselected.
struct CustomMenuPicker<SelectionValue: Hashable>: View {
    
    // MARK: - State Variables
    
    /// Holds the state of whether the picker is selected.
    @State private var isPickerPresented: Bool = false
    
    /// Holds the selected value from the picker.
    @Binding var selection: SelectionValue
    
    /// The placeholder text to be displayed.
    let placeholder: String
    
    /// The placeholder text color.
    let placeholderColor: Color
    
    /// The content of the picker.
    let content: AnyView
    
    // MARK: - View Components
    
    var body: some View {
        Group {
            if isPickerPresented {
                // The Picker is presented, show the picker
                Picker("", selection: $selection) {
                    content
                }
                .pickerStyle(MenuPickerStyle())
                .onTapGesture {
                    isPickerPresented.toggle()
                }
            } else {
                // The Picker is not presented, show the placeholder
                Text(placeholder)
                    .foregroundColor(placeholderColor)
                    .onTapGesture {
                        isPickerPresented.toggle()
                    }
            }
        }
    }
}

// MARK: - Utility Functions

/// Provides a preview of the CustomMenuPicker.
struct CustomMenuPicker_Previews: PreviewProvider {
    static var previews: some View {
        CustomMenuPicker(selection: .constant(1), placeholder: "Select Item", placeholderColor: .green, content: AnyView(
            VStack {
                Text("Item 1").tag(1)
                Text("Item 2").tag(2)
                Text("Item 3").tag(3)
            }
        ))
    }
}
