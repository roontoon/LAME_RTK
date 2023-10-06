/*
  File Name: Lame_RTK_EditView.swift
  Created by: Roontoon
  Date: 9/5/23
  Last Updated: 10/6/23
  Documentation Date and Time: 10/6/23 - 14:00
  Description: This file contains the EditView struct, which is responsible for editing GPS data points.
*/

import SwiftUI    // Importing the SwiftUI framework for building the user interface
import CoreData    // Importing CoreData for data persistence

// MARK: - EditView Struct Definition
// This section defines the main EditView struct which is a SwiftUI View.
struct EditView: View {
    // CoreData managed object context to interact with the data model
    @Environment(\.managedObjectContext) private var viewContext
    
    // An instance of GPSDataPoint that will be edited
    var dataPoint: GPSDataPoint
    
    // MARK: - State Variables for Editing
    // These variables hold the new values for each attribute of the GPSDataPoint.
    
    // A string to hold the new latitude value. Initialized with a default value.
    @State private var newLatitude: String = "0.0000000"
    
    // A string to hold the new longitude value. Initialized with a default value.
    @State private var newLongitude: String = "0.0000000"
    
    // A double to hold the new altitude value. Initialized with 0.0.
    @State private var newAltitude: Double = 0.0
    
    // (The rest of the State variables will go here)
    // A double to hold the new speed value. Initialized with 0.0.
    @State private var newSpeed: Double = 0.0
    
    // A double to hold the new heading value. Initialized with 0.0.
    @State private var newHeading: Double = 0.0
    
    // A double to hold the new course value. Initialized with 0.0.
    @State private var newCourse: Double = 0.0
    
    // A double to hold the new horizontal accuracy value. Initialized with 0.0.
    @State private var newHorizontalAccuracy: Double = 0.0
    
    // A double to hold the new vertical accuracy value. Initialized with 0.0.
    @State private var newVerticalAccuracy: Double = 0.0
    
    // A double to hold the new barometric pressure value. Initialized with 0.0.
    @State private var newBarometricPressure: Double = 0.0
    
    // A double to hold the new distance traveled value. Initialized with 0.0.
    @State private var newDistanceTraveled: Double = 0.0
    
    // A double to hold the new proximity to a specific location value. Initialized with 0.0.
    @State private var newProximityToSpecificLocation: Double = 0.0
    
    // A string to hold the new entry type value. Initialized with "Perimeter".
    @State private var newEntryType: String = "Perimeter"
    
    // A string to hold the new mowing pattern value. Initialized as an empty string.
    @State private var newMowingPattern: String = ""
    
    // A string to hold the new map ID value. Initialized as an empty string.
    @State private var newMapID: String = ""
    
    // A Date to hold the new timestamp value. Initialized with the current date and time.
    @State private var newTimestamp: Date = Date()
    
    // A Date to hold the new estimated time of arrival value. Initialized with the current date and time.
    @State private var newEstimatedTimeOfArrival: Date = Date()
    
    // An array of possible entry types for GPS data points
    let entryTypes = ["Perimeter", "Exclusion", "Charging"]

    // MARK: - SwiftUI Body
    // The body is where we define the visual components of the view.
    var body: some View {
        // Using Form to group the input fields and buttons.
        Form {
            // MARK: - Edit Fields Section
            // This section contains text fields and pickers for editing the GPS data point attributes.
            Section(header: Text("Edit Fields")) {
                // HStack for editing Latitude
                HStack {
                    Text("Latitude:")
                    TextField("Latitude", text: $newLatitude)
                        .keyboardType(.decimalPad)  // Use decimal keyboard
                }
                
                // HStack for editing Longitude
                HStack {
                    Text("Longitude:")
                    TextField("Longitude", text: $newLongitude)
                        .keyboardType(.decimalPad)  // Use decimal keyboard
                }
                
                // (The rest of the editing fields go here; similar to the Latitude and Longitude fields)
            }
            
            // MARK: - Action Buttons Section
            // This section contains buttons for saving changes and deleting the record.
            Section {
                // Button to trigger the saveChanges function
                Button("Save Changes") {
                    saveChanges()
                }
                
                // Button to trigger the deleteRecord function
                Button("Delete Record") {
                    deleteRecord()
                }
            }
        }
        // Load existing data when the view appears
        .onAppear {
            loadData()
        }
    }
    
    // MARK: - Data Loading Function
    // This function populates the state variables with existing data from the GPSDataPoint instance.
    private func loadData() {
        newLatitude = String(format: "%.7f", dataPoint.latitude)  // Convert latitude to string with 7 decimal places
        newLongitude = String(format: "%.7f", dataPoint.longitude)  // Convert longitude to string with 7 decimal places
        newAltitude = dataPoint.altitude  // Load existing altitude
        newSpeed = dataPoint.speed  // Load existing speed
        newHeading = dataPoint.heading  // Load existing heading
        newCourse = dataPoint.course  // Load existing course
        newHorizontalAccuracy = dataPoint.horizontalAccuracy  // Load existing horizontal accuracy
        newVerticalAccuracy = dataPoint.verticalAccuracy  // Load existing vertical accuracy
        newBarometricPressure = dataPoint.barometricPressure  // Load existing barometric pressure
        newDistanceTraveled = dataPoint.distanceTraveled  // Load existing distance traveled
        newProximityToSpecificLocation = dataPoint.proximityToSpecificLocation  // Load existing proximity to a specific location
        newEntryType = dataPoint.entryType ?? "Perimeter"  // Load existing entry type or use "Perimeter" as a default
        newMowingPattern = dataPoint.mowingPattern ?? ""  // Load existing mowing pattern or use an empty string as a default
        newMapID = dataPoint.mapID ?? ""  // Load existing map ID or use an empty string as a default
        newTimestamp = dataPoint.timestamp ?? Date()  // Load existing timestamp or use the current date and time as a default
        newEstimatedTimeOfArrival = dataPoint.estimatedTimeOfArrival ?? Date()  // Load existing estimated time of arrival or use the current date and time as a default
    }
    
    // MARK: - Save Changes Function
    // This function saves the changes made to the GPSDataPoint instance.
    private func saveChanges() {
        if let latitude = Double(newLatitude) {  // Convert newLatitude to Double
            dataPoint.latitude = latitude  // Update latitude
        }
        if let longitude = Double(newLongitude) {  // Convert newLongitude to Double
            dataPoint.longitude = longitude  // Update longitude
        }
        // (The rest of the code for saving changes to the GPSDataPoint instance)
    }
    
    // MARK: - Delete Record Function
    // This function deletes the GPSDataPoint instance from the CoreData context.
    private func deleteRecord() {
        viewContext.delete(dataPoint)  // Delete the data point from the managed object context
        
        do {
            try viewContext.save()  // Save the changes to the managed object context
        } catch {
            let nsError = error as NSError  // Convert the error to NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")  // Log the error and terminate the app
        }
    }

}
