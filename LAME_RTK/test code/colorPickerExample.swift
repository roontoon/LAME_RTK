//
//  colorPickerExample.swift
//  LAME_RTK
//
//  Created by Roontoon on 10/27/23.
//

import SwiftUI // MARK: Import Statements

// MARK: Struct/Class Definitions
struct ColorPickerExample: View {
    
    // MARK: State Variables
    @State private var selectedColor = "Red"
    let colors = ["Red", "Green", "Blue"]
    
    // MARK: View Components
    var body: some View {
        VStack {
            Text("Select a color:")
            
            // Picker with colored text
            Picker("Colors", selection: $selectedColor) {
                ForEach(colors, id: \.self) { color in
                    Text(color)
                        .foregroundColor(getColor(name: color)) // Change text color based on the color name
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
    
    // MARK: Utility Functions
    /// Returns a SwiftUI.Color based on the given color name
    ///
    /// - Parameters:
    ///   - name: The name of the color (e.g., "Red")
    /// - Returns: A SwiftUI.Color corresponding to the given name
    func getColor(name: String) -> Color {
        switch name {
        case "Red":
            return .red
        case "Green":
            return .green
        case "Blue":
            return .blue
        default:
            return .black
        }
    }
}

// MARK: Preview
struct ColorPickerExample_Previews: PreviewProvider {
    static var previews: some View {
        ColorPickerExample()
    }
}
