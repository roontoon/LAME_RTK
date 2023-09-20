// We're using tools from SwiftUI and CoreData to make our app.
import SwiftUI
import CoreData

// This is a screen that shows details about a GPS data point.
struct GPSDataListView: View {
    // This helps us talk to the place where the GPS data is stored.
    @Environment(\.managedObjectContext) private var viewContext
    
    // This keeps track of a single GPS data point and any changes to it.
    @ObservedObject var gpsDataPoint: GPSDataPoint
    
    // These are boxes to hold new information that we might want to save.
    @State private var newTimestamp: Date  // For the date and time
    @State private var newLongitude: Double  // For how far East or West
    @State private var newLatitude: Double  // For how far North or South
    @State private var newAltitude: Double  // For how high up
    @State private var newSpeed: Double  // For how fast moving
    @State private var newHeading: Double  // For which direction facing
    @State private var newCourse: Double  // For which direction moving
    @State private var newHorizontalAccuracy: Double  // For how sure we are about East/West location
    @State private var newVerticalAccuracy: Double  // For how sure we are about up/down location
    @State private var newBarometricPressure: Double  // For the air pressure
    @State private var newDistanceTraveled: Double  // For how far traveled
    @State private var newEstimatedTimeOfArrival: Date  // For when we'll get there
    @State private var newProximityToSpecificLocation: Double  // For how close we are to a specific place
    @State private var newEntryType: String  // For the type of GPS point
    @State private var newMowingPattern: String  // For the pattern of mowing
    @State private var newMapID: String  // For the ID of the map

    // This sets up the screen with the current GPS data point.
    init(gpsDataPoint: GPSDataPoint) {
        self.gpsDataPoint = gpsDataPoint
        // We start the boxes with the current information.
        self._newTimestamp = State(initialValue: gpsDataPoint.timestamp ?? Date())
        self._newLongitude = State(initialValue: gpsDataPoint.longitude)
        self._newLatitude = State(initialValue: gpsDataPoint.latitude)
        // We also start the other boxes with some default information.
        self._newAltitude = State(initialValue: gpsDataPoint.altitude)
        self._newSpeed = State(initialValue: gpsDataPoint.speed)
        self._newHeading = State(initialValue: gpsDataPoint.heading)
        self._newCourse = State(initialValue: gpsDataPoint.course)
        self._newHorizontalAccuracy = State(initialValue: gpsDataPoint.horizontalAccuracy)
        self._newVerticalAccuracy = State(initialValue: gpsDataPoint.verticalAccuracy)
        self._newBarometricPressure = State(initialValue: gpsDataPoint.barometricPressure)
        self._newDistanceTraveled = State(initialValue: gpsDataPoint.distanceTraveled)
        self._newEstimatedTimeOfArrival = State(initialValue: gpsDataPoint.estimatedTimeOfArrival ?? Date())
        self._newProximityToSpecificLocation = State(initialValue: gpsDataPoint.proximityToSpecificLocation)
        self._newEntryType = State(initialValue: gpsDataPoint.entryType ?? "")
        self._newMowingPattern = State(initialValue: gpsDataPoint.mowingPattern ?? "")
        self._newMapID = State(initialValue: gpsDataPoint.mapID ?? "")
    }

    // This is what the screen looks like.
    var body: some View {
        
        // We're making a scrollable area so you can see everything, even if it's a lot!
        ScrollView {
            // We're stacking things vertically, like a tower of blocks.
            VStack {
                
                // This part is for picking a date and time.
                HStack {
                    // This is the label that says "Timestamp:"
                    Text("Timestamp:")
                        .font(.caption2)
                        .frame(width: 200, alignment: .leading)  // We give it some space so it lines up nicely.
                        .padding(.leading, 20)  // Add 20 points of space to the left

                    // This is the calendar picker for choosing a date and time.
                    DatePicker("", selection: $newTimestamp, displayedComponents: .hourAndMinute)
                        .font(.caption2)
                        .accentColor(Color.purple)  // We color it purple because purple is awesome!
                }
                
                // This part is for typing how far East or West you are.
                HStack {
                    // This is the label that says "Longitude:"
                    Text("Longitude:")
                        .font(.caption2)
                        .frame(width: 200, alignment: .leading)  // We give it some space so it lines up nicely.
                        .padding(.leading, 20)  // Add 20 points of space to the left

                    // This is where you can type the longitude.
                    TextField("", value: $newLongitude, formatter: GPSFormatter())
                        .font(.caption2)
                        .foregroundColor(Color.red)  // We color it red to make it stand out.
                }
                
                // This part is for typing how far North or South you are.
                HStack {
                    // This is the label that says "Latitude:"
                    Text("Latitude:")
                        .font(.caption2)
                        .frame(width: 200, alignment: .leading)  // We give it some space so it lines up nicely.
                        .padding(.leading, 20)  // Add 20 points of space to the left
                    
                    // This is where you can type the latitude.
                    TextField("", value: $newLatitude, formatter: GPSFormatter())
                        .font(.caption2)
                        .foregroundColor(Color.red)  // We color it red to make it stand out.
                }
                
                // And you can do the same for all the other boxes to make them look neat!
                
                // This part is for typing how high up you are.
                HStack {
                    Text("Altitude:")
                        .font(.caption2)
                        .frame(width: 200, alignment: .leading)
                        .padding(.leading, 20)  // Add 20 points of space to the left
                    
                    TextField("", value: $newAltitude, formatter: NumberFormatter())
                        .font(.caption2)
                        .foregroundColor(Color.blue)
                }
                
                // This part is for typing how fast you're moving.
                HStack {
                    Text("Speed:")
                        .font(.caption2)
                        .frame(width: 200, alignment: .leading)
                        .padding(.leading, 20)  // Add 20 points of space to the left
                    
                    TextField("", value: $newSpeed, formatter: NumberFormatter())
                        .font(.caption2)
                        .foregroundColor(Color.blue)
                }
                
                // This part is for typing which direction you're facing.
                HStack {
                    Text("Heading:")
                        .font(.caption2)
                        .frame(width: 200, alignment: .leading)
                        .padding(.leading, 20)  // Add 20 points of space to the left
                    
                    TextField("", value: $newHeading, formatter: NumberFormatter())
                        .font(.caption2)
                        .foregroundColor(Color.blue)
                }
                
                // This part is for typing which direction you're moving in.
                HStack {
                    Text("Course:")
                        .font(.caption2)
                        .frame(width: 200, alignment: .leading)
                        .padding(.leading, 20)  // Add 20 points of space to the left
                    
                    TextField("", value: $newCourse, formatter: NumberFormatter())
                        .font(.caption2)
                        .foregroundColor(Color.blue)
                }
                
                // This part is for typing how sure you are about your East/West location.
                HStack {
                    Text("Horiz. Accuracy:")
                        .font(.caption2)
                        .frame(width: 200, alignment: .leading)
                        .padding(.leading, 20)  // Add 20 points of space to the left
                    
                    TextField("", value: $newHorizontalAccuracy, formatter: NumberFormatter())
                        .font(.caption2)
                        .foregroundColor(Color.blue)
                }
                
                // This part is for typing how sure you are about your up/down location.
                HStack {
                    Text("Vert. Accuracy:")
                        .font(.caption2)
                        .frame(width: 200, alignment: .leading)
                        .padding(.leading, 20)  // Add 20 points of space to the left
                    
                    TextField("", value: $newVerticalAccuracy, formatter: NumberFormatter())
                        .font(.caption2)
                        .foregroundColor(Color.blue)
                }
                
                // This part is for typing the air pressure around you.
                HStack {
                    Text("Barometric Pres.:")
                        .font(.caption2)
                        .frame(width: 200, alignment: .leading)
                        .padding(.leading, 20)  // Add 20 points of space to the left
                    
                    TextField("", value: $newBarometricPressure, formatter: NumberFormatter())
                    .font(.caption2)
                }
                
                // This part is for typing how far you've traveled.
                HStack {
                    Text("Distance:")
                        .font(.caption2)
                        .frame(width: 200, alignment: .leading)
                        .padding(.leading, 20)  // Add 20 points of space to the left
                    
                    TextField("", value: $newDistanceTraveled, formatter: NumberFormatter())
                        .font(.caption2)
                }
                
                HStack {
                    Text("ETA:")  // This is the title for the field.
                        .font(.caption2)  // This makes the title very small.
                        .frame(width: 200, alignment: .leading)  // This gives it some space so it lines up nicely.
                        .padding(.leading, 20)  // Add 20 points of space to the left
                    
                    DatePicker("", selection: $newEstimatedTimeOfArrival, displayedComponents: .hourAndMinute)
                        .font(.caption2)  // This makes the DatePicker text very small, just like the title!
                }
                
                // This part is for typing how close you are to a specific place.
                HStack {
                    Text("Proximity:")
                        .font(.caption2)
                        .frame(width: 200, alignment: .leading)
                        .padding(.leading, 20)  // Add 20 points of space to the left
                    TextField("", value: $newProximityToSpecificLocation, formatter: NumberFormatter())
                    .font(.caption2)
                }
                
                // This part is for typing what kind of GPS point this is.
                HStack {
                    Text("Entry Type:")
                        .font(.caption2)
                        .frame(width: 200, alignment: .leading)
                        .padding(.leading, 20)  // Add 20 points of space to the left
                    TextField("", text: $newEntryType)
                        .font(.caption2)
                }
                
                // This part is for typing the pattern of mowing.
                HStack {
                    Text("Mowing Pattern:")
                        .font(.caption2)
                        .frame(width: 200, alignment: .leading)
                        .padding(.leading, 20)  // Add 20 points of space to the left
                    
                    TextField("", text: $newMowingPattern)
                        .font(.caption2)
                }
                
                // This part is for typing the ID of the map you're using.
                HStack {
                    Text("Map ID:")
                        .font(.caption2)
                        .frame(width: 200, alignment: .leading)
                        .padding(.leading, 20)  // Add 20 points of space to the left
                    
                    TextField("", text: $newMapID)
                        .font(.caption2)
                        
                }
            }
        }

 

        // We add a Save button to keep our changes.
        .navigationBarItems(trailing: Button("Save") {
            // When we press Save, this happens.
            saveChanges()
        })
        .accentColor(Color.purple)  // We make other things purple too!
    }
    
    // This is how we save our changes.
    private func saveChanges() {
        // We make the changes look smooth.
        withAnimation {
            // We update the GPS data point with our new information.
            gpsDataPoint.timestamp = newTimestamp
            gpsDataPoint.latitude = newLatitude
            gpsDataPoint.longitude = newLongitude
            gpsDataPoint.altitude = newAltitude
            gpsDataPoint.speed = newSpeed
            gpsDataPoint.heading = newHeading
            gpsDataPoint.course = newCourse
            gpsDataPoint.horizontalAccuracy = newHorizontalAccuracy
            gpsDataPoint.verticalAccuracy = newVerticalAccuracy
            gpsDataPoint.barometricPressure = newBarometricPressure
            gpsDataPoint.distanceTraveled = newDistanceTraveled
            gpsDataPoint.estimatedTimeOfArrival = newEstimatedTimeOfArrival
            gpsDataPoint.proximityToSpecificLocation = newProximityToSpecificLocation
            gpsDataPoint.entryType = newEntryType
            gpsDataPoint.mowingPattern = newMowingPattern
            gpsDataPoint.mapID = newMapID
            
            // We try to save our changes.
            do {
                try viewContext.save()
            } catch {
                // If something goes wrong, we show an error.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    // This makes sure our numbers look right.
    func GPSFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal  // We want decimal numbers.
        formatter.maximumFractionDigits = 6  // Up to 8 numbers after the dot.
        formatter.minimumFractionDigits = 6  // At least 8 numbers after the dot.
        return formatter
    }
}
