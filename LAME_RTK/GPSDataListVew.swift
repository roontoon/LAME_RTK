// We're using tools from SwiftUI and CoreData to make our app.
import SwiftUI
import CoreData

// This is a screen that shows details about a GPS data point.
struct GPSDataListVew: View {
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
        self._newAltitude = State(initialValue: 0.0)
        self._newSpeed = State(initialValue: 0.0)
        self._newHeading = State(initialValue: 0.0)
        self._newCourse = State(initialValue: 0.0)
        self._newHorizontalAccuracy = State(initialValue: 0.0)
        self._newVerticalAccuracy = State(initialValue: 0.0)
        self._newBarometricPressure = State(initialValue: 0.0)
        self._newDistanceTraveled = State(initialValue: 0.0)
        self._newEstimatedTimeOfArrival = State(initialValue: Date())
        self._newEntryType = State(initialValue: "")
        self._newMowingPattern = State(initialValue: "")
        self._newMapID = State(initialValue: "")
    }


    // This is what the screen looks like.
    var body: some View {
        // We use a form to make it easy to enter information.
        Form {
            // A picker for the date and time.
            DatePicker("Timestamp", selection: $newTimestamp, displayedComponents: .hourAndMinute)
                .accentColor(Color.purple)  // We make it purple because it's fun!
            
            // A box to type in how far East or West.
            TextField("Longitude", value: $newLongitude, formatter: GPSFormatter())
                .foregroundColor(Color.red)  // We make it red to stand out.
            
            // A box to type in how far North or South.
            TextField("Latitude", value: $newLatitude, formatter: GPSFormatter())
                .foregroundColor(Color.green)  // We make it green because it's cool.
            
            // A box to type in how high up we are.
            TextField("Altitude", value: $newAltitude, formatter: GPSFormatter())
            
            // A box to type in how fast we are moving.
            TextField("Speed", value: $newSpeed, formatter: GPSFormatter())
            
            // ... (other boxes for new attributes)
            
            // A box to type in the type of GPS point.
            TextField("Entry Type", text: $newEntryType)
            
            // A box to type in the pattern of mowing.
            TextField("Mowing Pattern", text: $newMowingPattern)
            
            // A box to type in the ID of the map.
            TextField("Map ID", text: $newMapID)
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
      /*/      gpsDataPoint.altitude = newAltitude
            gpsDataPoint.speed = newSpeed
            gpsDataPoint.heading = newHeading
            gpsDataPoint.course = newCourse
            gpsDataPoint.horizontalAccuracy = newHorizontalAccuracy
            gpsDataPoint.verticalAccuracy = newVerticalAccuracy
            gpsDataPoint.barometricPressure = newBarometricPressure
            gpsDataPoint.distanceTraveled = newDistanceTraveled
            gpsDataPoint.estimatedTimeOfArrival = newEstimatedTimeOfArrival
            gpsDataPoint.entryType = newEntryType
            gpsDataPoint.mowingPattern = newMowingPattern
            gpsDataPoint.mapID = newMapID
            */
            
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
        formatter.maximumFractionDigits = 8  // Up to 8 numbers after the dot.
        formatter.minimumFractionDigits = 8  // At least 8 numbers after the dot.
        return formatter
    }
}
