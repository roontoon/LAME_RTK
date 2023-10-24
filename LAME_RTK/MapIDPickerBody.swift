// MapIDPickerBody.swift
// Date and Time Documented: October 23, 2023, 10:30 AM
//
// This file defines the body of the MapIDPicker SwiftUI view.
// It contains the UI elements that make up the Picker, as well as behavior for selection changes.
// The Picker is designed to float over other views, making it ideal for map interfaces.

import SwiftUI

// MARK: - MapIDPickerBody Struct Definition
/// The main struct that defines the MapIDPickerBody.
struct MapIDPickerBody: View {
    
    // MARK: - Properties and Variables
    /// Declare a state for managing the selected Map ID
    @Binding var selectedMapID: String
    
    /// Declare an array to hold the Map IDs
    let mapIDs: [String]
    
    // MARK: - Body Definition
    /// The body of the MapIDPickerBody.
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    //Text("***** debug")
                    Spacer()
                    Picker("Select Map ID", selection: $selectedMapID.onChange { newValue in
                        print("Debug: Picker selected \(newValue)") // Debug Statement
                    }) {
                        ForEach(mapIDs, id: \.self) { mapID in
                            Text(mapID)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .padding()
                }
            }
        }
        .onAppear {
            print("**** MapIDPickerBody appeared") // Existing Debug Statement
        }
    }
}

// MARK: - Binding onChange Extension
/// This extension adds an onChange handler to SwiftUI's Binding
extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}
