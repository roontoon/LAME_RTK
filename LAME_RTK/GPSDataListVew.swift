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
        // We use a form to make it easy to enter information.
        // We use a scroll view so you can scroll up and down if there's too much stuff.
        ScrollView {
            // We use a vertical stack to put things on top of each other.
            VStack {
                
                // This is a calendar picker for the date and time.
                HStack {
                    Text("Timestamp:")  // This is the name of the field.
                    DatePicker("", selection: $newTimestamp, displayedComponents: .hourAndMinute)
                        .accentColor(Color.purple)  // We make the calendar picker purple because purple is a fun color!
                }
                
                // This is a box where you can type how far East or West you are.
                /*
                 HStack {
                    Text("Longitude:")  // This is the name of the field.
                
                    TextField("", text: Binding(
                        get: { String(newLongitude) },  // We turn the number into text so you can see it.
                        set: { newLongitude = Double($0) ?? 0.0 }  // We turn the text back into a number when you type.
                    ))
                    .foregroundColor(Color.red)  // We make the text red to make it stand out.
                }
                 */
                Text("Longitude:")  // This is the name of the field.
                TextField("", value: $newLongitude, formatter: GPSFormatter())
                    .foregroundColor(Color.red)  // We make the text red to make it stand out.

                // This is a box where you can type how far North or South you are.
                HStack {
                    Text("Latitude:")  // This is the name of the field.
                    TextField("", value: $newLatitude, formatter: GPSFormatter())
                        .foregroundColor(Color.red)  // We make the text red to make it stand out.
                }
                
                // This is a box where you can type how high up in the sky you are.
                HStack {
                    Text("Altitude:")  // This is the name of the field.
                    TextField("", value: $newAltitude, formatter: NumberFormatter())
                        .foregroundColor(Color.blue)  // We make the text blue to make it stand out.
                }
                
                // This is a box where you can type how fast you are moving.
                HStack {
                    Text("Speed:")  // This is the name of the field.
                    TextField("", value: $newSpeed, formatter: NumberFormatter())
                        .foregroundColor(Color.blue)  // We make the text blue to make it stand out.
                }
                
                // This is a box where you can type which direction your face is pointing.
                HStack {
                    Text("Heading:")  // This is the name of the field.
                    TextField("", value: $newHeading, formatter: NumberFormatter())
                        .foregroundColor(Color.blue)  // We make the text blue to make it stand out.
                }
                
                // This is a box where you can type which direction you are moving.
                HStack {
                    Text("Course:")  // This is the name of the field.
                    TextField("", value: $newCourse, formatter: NumberFormatter())
                        .foregroundColor(Color.blue)  // We make the text blue to make it stand out.
                }
                
                // This is a box where you can type how sure you are about your East/West location.
                HStack {
                    Text("Horizontal Accuracy:")  // This is the name of the field.
                    TextField("", value: $newHorizontalAccuracy, formatter: NumberFormatter())
                        .foregroundColor(Color.blue)  // We make the text blue to make it stand out.
                }
                
                // This is a box where you can type how sure you are about your up/down location.
                HStack {
                    Text("Vertical Accuracy:")  // This is the name of the field.
                    TextField("", value: $newVerticalAccuracy, formatter: NumberFormatter())
                        .foregroundColor(Color.blue)  // We make the text blue to make it stand out.
                }
                
                // This is a box where you can type the air pressure around you.
                HStack {
                    Text("Barometric Pressure:")  // This is the name of the field.
                    TextField("", value: $newBarometricPressure, formatter: NumberFormatter())
                }
                
                // This is a box where you can type how far you've traveled.
                HStack {
                    Text("Distance Traveled:")  // This is the name of the field.
                    TextField("", value: $newDistanceTraveled, formatter: NumberFormatter())
                }
                
                // This is another calendar picker for when you'll get to your destination.
                HStack {
                    Text("Estimated Time of Arrival:")  // This is the name of the field.
                    DatePicker("", selection: $newEstimatedTimeOfArrival, displayedComponents: .hourAndMinute)
                }
                
                // This is a box where you can type how close you are to a specific place.
                HStack {
                    Text("Proximity to Specific Location:")  // This is the name of the field.
                    TextField("", value: $newProximityToSpecificLocation, formatter: NumberFormatter())
                }
                
                // This is a box where you can type what kind of GPS point this is.
                HStack {
                    Text("Entry Type:")  // This is the name of the field.
                    TextField("", text: $newEntryType)
                }
                
                // This is a box where you can type the pattern of mowing.
                HStack {
                    Text("Mowing Pattern:")  // This is the name of the field.
                    TextField("", text: $newMowingPattern)
                }
                
                // This is a box where you can type the ID of the map you're using.
                HStack {
                    Text("Map ID:")  // This is the name of the field.
                    TextField("", text: $newMapID)
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
