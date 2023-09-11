import SwiftUI
import CoreData

struct EditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var dataPoint: GPSDataPoint
    
    // Variables for editing all attributes
    @State private var newLatitude: String = "0.00000000"
    @State private var newLongitude: String = "0.00000000"
    @State private var newAltitude: Double = 0.0
    @State private var newSpeed: Double = 0.0
    @State private var newHeading: Double = 0.0
    @State private var newCourse: Double = 0.0
    @State private var newHorizontalAccuracy: Double = 0.0
    @State private var newVerticalAccuracy: Double = 0.0
    @State private var newBarometricPressure: Double = 0.0
    @State private var newDistanceTraveled: Double = 0.0
    @State private var newProximityToSpecificLocation: Double = 0.0
    @State private var newEntryType: String = "Perimeter"
    @State private var newMowingPattern: String = ""
    @State private var newMapID: String = ""
    @State private var newTimestamp: Date = Date()
    @State private var newEstimatedTimeOfArrival: Date = Date()
    
    // Entry types
    let entryTypes = ["Perimeter", "Exclusion", "Charging"]
    
    var body: some View {
        Form {
            Section(header: Text("Edit Fields")) {
                HStack {
                    Text("Latitude:")
                    TextField("Latitude", text: $newLatitude)
                        .keyboardType(.decimalPad)
                }
                HStack {
                    Text("Longitude:")
                    TextField("Longitude", text: $newLongitude)
                        .keyboardType(.decimalPad)
                }
                HStack {
                    Text("Altitude:")
                    TextField("Altitude", value: $newAltitude, formatter: NumberFormatter())
                }
                HStack {
                    Text("Speed:")
                    TextField("Speed", value: $newSpeed, formatter: NumberFormatter())
                }
                HStack {
                    Text("Heading:")
                    TextField("Heading", value: $newHeading, formatter: NumberFormatter())
                }
                HStack {
                    Text("Course:")
                    TextField("Course", value: $newCourse, formatter: NumberFormatter())
                }
                HStack {
                    Text("Horizontal Accuracy:")
                    TextField("Horizontal Accuracy", value: $newHorizontalAccuracy, formatter: NumberFormatter())
                }
                HStack {
                    Text("Vertical Accuracy:")
                    TextField("Vertical Accuracy", value: $newVerticalAccuracy, formatter: NumberFormatter())
                }
                HStack {
                    Text("Barometric Pressure:")
                    TextField("Barometric Pressure", value: $newBarometricPressure, formatter: NumberFormatter())
                }
                HStack {
                    Text("Distance Traveled:")
                    TextField("Distance Traveled", value: $newDistanceTraveled, formatter: NumberFormatter())
                }
                HStack {
                    Text("Proximity To Specific Location:")
                    TextField("Proximity To Specific Location", value: $newProximityToSpecificLocation, formatter: NumberFormatter())
                }
                HStack {
                    Text("Entry Type:")
                    Picker("Entry Type", selection: $newEntryType) {
                        ForEach(entryTypes, id: \.self) {
                            Text($0)
                        }
                    }
                }
                HStack {
                    Text("Mowing Pattern:")
                    TextField("Mowing Pattern", text: $newMowingPattern)
                }
                HStack {
                    Text("Map ID:")
                    TextField("Map ID", text: $newMapID)
                }
                DatePicker("Timestamp", selection: $newTimestamp, displayedComponents: [.date, .hourAndMinute])
                DatePicker("Estimated Time of Arrival", selection: $newEstimatedTimeOfArrival, displayedComponents: [.date, .hourAndMinute])
            }
            
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
    
    private func loadData() {
        newLatitude = String(format: "%.8f", dataPoint.latitude)
        newLongitude = String(format: "%.8f", dataPoint.longitude)
        newAltitude = dataPoint.altitude
        newSpeed = dataPoint.speed
        newHeading = dataPoint.heading
        newCourse = dataPoint.course
        newHorizontalAccuracy = dataPoint.horizontalAccuracy
        newVerticalAccuracy = dataPoint.verticalAccuracy
        newBarometricPressure = dataPoint.barometricPressure
        newDistanceTraveled = dataPoint.distanceTraveled
        newProximityToSpecificLocation = dataPoint.proximityToSpecificLocation
        newEntryType = dataPoint.entryType ?? "Perimeter"
        newMowingPattern = dataPoint.mowingPattern ?? ""
        newMapID = dataPoint.mapID ?? ""
        newTimestamp = dataPoint.timestamp ?? Date()
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
