

/// File Name: Lame_RTK_EditView.swift
/// Created by: Roontoon
/// Date: 9/5/23
/// Last Updated: 10/6/23
/// Documentation Date and Time: 10/6/23 - 14:00
/// Description: This file contains the EditView struct, which is responsible for editing GPS data points.
///
import SwiftUI
import CoreData

/// MARK: - EditView Struct Definition
/// This section defines the main EditView struct which is a SwiftUI View.
///
struct EditView: View {
    
    /// CoreData managed object context to interact with the data model
    @Environment(\.managedObjectContext) private var viewContext
    
    /// An instance of GPSDataPoint that will be edited
    var dataPoint: GPSDataPoint
    
    /// MARK: - State Variables for Editing
    /// These variables hold the new values for each attribute of the GPSDataPoint.
    
    /// A string to hold the new latitude value. Initialized with a default value.
    @State private var newLatitude: String = "0.0000000"
    
    /// A string to hold the new longitude value. Initialized with a default value.
    @State private var newLongitude: String = "0.0000000"
    
    /// A double to hold the new altitude value. Initialized with 0.0.
    @State private var newAltitude: Double = 0.0
    
    /// (The rest of the State variables will go here)
    /// A double to hold the new speed value. Initialized with 0.0.
    @State private var newSpeed: Double = 0.0
    
    /// A double to hold the new heading value. Initialized with 0.0.
    @State private var newHeading: Double = 0.0
    
    /// A double to hold the new course value. Initialized with 0.0.
    @State private var newCourse: Double = 0.0
    
    /// A double to hold the new horizontal accuracy value. Initialized with 0.0.
    @State private var newHorizontalAccuracy: Double = 0.0
    
    /// A double to hold the new vertical accuracy value. Initialized with 0.0.
    @State private var newVerticalAccuracy: Double = 0.0
    
    /// A double to hold the new barometric pressure value. Initialized with 0.0.
    @State private var newBarometricPressure: Double = 0.0
    
    /// A double to hold the new distance traveled value. Initialized with 0.0.
    @State private var newDistanceTraveled: Double = 0.0
    
    /// A double to hold the new proximity to a specific location value. Initialized with 0.0.
    @State private var newProximityToSpecificLocation: Double = 0.0
    
    /// A string to hold the new entry type value. Initialized with "Perimeter".
    @State private var newEntryType: String = "Perimeter"
    
    /// A string to hold the new mowing pattern value. Initialized as an empty string.
    @State private var newMowingPattern: String = ""
    
    /// A string to hold the new map ID value. Initialized as an empty string.
    @State private var newMapID: String = ""
    
    /// A Date to hold the new timestamp value. Initialized with the current date and time.
    @State private var newTimestamp: Date = Date()
    
    /// A Date to hold the new estimated time of arrival value. Initialized with the current date and time.
    @State private var newEstimatedTimeOfArrival: Date = Date()
    
    /// An array of possible entry types for GPS data points
    let entryTypes = ["Perimeter", "Exclusion", "Charging"]
    
    /// MARK: - SwiftUI Body
    /// The body is where we define the visual components of the view.
    
    var body: some View {
        /// Using Form to group the input fields and buttons.
        
        Form {
            /// MARK: - Edit Fields Section
            /// This section contains text fields and pickers for editing the GPS data point attributes.
            
            Section(header: Text("Edit Fields")) {
                
                /// HStack for editing Latitude
              /*  HStack {
                    Text("Latitude:")
                    TextField("Latitude", text: $newLatitude)
                        .keyboardType(.decimalPad)
                }
                */
                /// HStack for editing Longitude
                HStack {
                    Text("Longitude:")
                    TextField("Longitude", text: $newLongitude)
                        .keyboardType(.decimalPad)
                }
                /// HStack for editing
                HStack {
                    Text("Altitude:")
                    TextField("Altitude", value: $newAltitude, formatter: NumberFormatter())
                }
                /// HStack for editing
                HStack {
                    Text("Speed:")
                    TextField("Speed", value: $newSpeed, formatter: NumberFormatter())
                }
                /// HStack for editing
                HStack {
                    Text("Heading:")
                    TextField("Heading", value: $newHeading, formatter: NumberFormatter())
                }
                /// HStack for editing
                HStack {
                    Text("Course:")
                    TextField("Course", value: $newCourse, formatter: NumberFormatter())
                }
                /// HStack for editing
                HStack {
                    Text("Horizontal Accuracy:")
                    TextField("Horizontal Accuracy", value: $newHorizontalAccuracy, formatter: NumberFormatter())
                }
                /// HStack for editing
                HStack {
                    Text("Vertical Accuracy:")
                    TextField("Vertical Accuracy", value: $newVerticalAccuracy, formatter: NumberFormatter())
                }
                /// HStack for editing
                HStack {
                    Text("Barometric Pressure:")
                    TextField("Barometric Pressure", value: $newBarometricPressure, formatter: NumberFormatter())
                }
                /// HStack for editing
                HStack {
                    Text("Distance Traveled:")
                    TextField("Distance Traveled", value: $newDistanceTraveled, formatter: NumberFormatter())
                }
                /// HStack for editing
                HStack {
                    Text("Proximity To Specific Location:")
                    TextField("Proximity To Specific Location", value: $newProximityToSpecificLocation, formatter: NumberFormatter())
                }
                /// HStack for editing
                HStack {
                    Text("Entry Type:")
                    Picker("Entry Type", selection: $newEntryType) {
                        ForEach(entryTypes, id: \.self) {
                            Text($0)
                        }
                    }
                }
                /// HStack for editing
                HStack {
                    Text("Mowing Pattern:")
                    TextField("Mowing Pattern", text: $newMowingPattern)
                }
                /// HStack for editing
                HStack {
                    Text("Map ID:")
                    TextField("Map ID", text: $newMapID)
                }
                DatePicker("Timestamp", selection: $newTimestamp, displayedComponents: [.date, .hourAndMinute])
                DatePicker("Estimated Time of Arrival", selection: $newEstimatedTimeOfArrival, displayedComponents: [.date, .hourAndMinute])
            }
            
            /// MARK: - Action Buttons Section
            /// This section contains buttons for saving changes and deleting the record.
            Section {
                Button("Save Changes") {
                    saveChanges()
                }
                
                Button("Delete Record") {
                    deleteRecord()
                }
            }
        }
        .onAppear {
            loadData()
        }
    }
    /// MARK: - Data Loading Function
    /// This function populates the state variables with existing data from the GPSDataPoint instance.
    
    private func loadData() {
        /// Convert latitude to string with 7 decimal places
        newLatitude = String(format: "%.7f", dataPoint.latitude)
  
        /// Convert longitude to string with 7 decimal places
        newLongitude = String(format: "%.7f", dataPoint.longitude)
  
        /// Load existing altitude
        newAltitude = dataPoint.altitude
        
        /// Load existing speed
        newSpeed = dataPoint.speed
        
        /// Load existing heading
        newHeading = dataPoint.heading
        
        /// Load existing course
        newCourse = dataPoint.course
        
        /// Load existing horizontal accuracy
        newHorizontalAccuracy = dataPoint.horizontalAccuracy
        
        /// Load existing vertical accuracy
        newVerticalAccuracy = dataPoint.verticalAccuracy
        
        /// Load existing barometric pressure
        newBarometricPressure = dataPoint.barometricPressure
 
        /// Load existing distance traveled
        newDistanceTraveled = dataPoint.distanceTraveled
        
        /// Load existing proximity to a specific location
        newProximityToSpecificLocation = dataPoint.proximityToSpecificLocation
        
        /// Load existing entry type or use "Perimeter" as a default
        newEntryType = dataPoint.entryType ?? "Perimeter"
        
        /// Load existing mowing pattern or use an empty string as a default
        newMowingPattern = dataPoint.mowingPattern ?? ""
        
        /// Load existing map ID or use an empty string as a default
        newMapID = dataPoint.mapID ?? ""
        
        /// Load existing timestamp or use the current date and time as a default
        newTimestamp = dataPoint.timestamp ?? Date()
        
        /// Load existing estimated time of arrival or use the current date and time as a default
        newEstimatedTimeOfArrival = dataPoint.estimatedTimeOfArrival ?? Date()
    }
    
    private func saveChanges() {
        if let latitude = Double(newLatitude) {
            dataPoint.latitude = latitude
        }
        if let longitude = Double(newLongitude) {
            dataPoint.longitude = longitude
        }
        dataPoint.altitude = newAltitude
        dataPoint.speed = newSpeed
        dataPoint.heading = newHeading
        dataPoint.course = newCourse
        dataPoint.horizontalAccuracy = newHorizontalAccuracy
        dataPoint.verticalAccuracy = newVerticalAccuracy
        dataPoint.barometricPressure = newBarometricPressure
        dataPoint.distanceTraveled = newDistanceTraveled
        dataPoint.proximityToSpecificLocation = newProximityToSpecificLocation
        dataPoint.entryType = newEntryType
        dataPoint.mowingPattern = newMowingPattern
        dataPoint.mapID = newMapID
        dataPoint.timestamp = newTimestamp
        dataPoint.estimatedTimeOfArrival = newEstimatedTimeOfArrival
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func deleteRecord() {
        viewContext.delete(dataPoint)
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

