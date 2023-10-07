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
                
                // This part is for showing the estimated time of arrival.
                
                // This part is for selecting how far North or south you are.
                HStack {
                    // This is the label that says "Latitude:"
                    Text("Latitude:")
                          .font(.body)
                          .frame(width: 150, alignment: .leading)
                          .padding(.leading, 20)  // Add padding only to the leading side
                    // Custom stepper
                    HStack {
                        // Minus button
                        Button(action: {
                            newLatitude -= 0.000001
                            newLatitude = round(1000000 * newLatitude) / 1000000  // Round to 6 decimal places
                        }) {
                            Text("-")
                                .font(.title)
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color.green)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                        }
                        Spacer()
                        // Display value
                        Text(String(format: "%.6f", newLatitude))
                            .font(.body)
                            .foregroundColor(Color.green)  // We color it red to make it stand out.
                        Spacer()
                        // Plus button
                        Button(action: {
                            newLatitude += 0.000001
                            newLatitude = round(1000000 * newLatitude) / 1000000  // Round to 6 decimal places
                        }) {
                            Text("+")
                                .font(.title)
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color.red)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                        }.padding(.trailing, 33)
                        Spacer()
                    }
                    //Spacer()
                }
                
                // This part is for selecting how far East or West you are.
                HStack {
                    // This is the label that says "Longitude:"
                    Text("Longitude:")
                        .font(.body)
                        .frame(width: 150, alignment: .leading)  // We give it some space so it lines up nicely.
                        .padding(.leading,20)
                    
                    
                    // Custom stepper
                    HStack {
                        // Minus button
                        Button(action: {
                            newLongitude -= 0.000001
                            newLongitude = round(1000000 * newLongitude) / 1000000  // Round to 6 decimal places
                        }) {
                            Text("-")
                                .font(.title)
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color.blue)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                        }
                        Spacer()
                        // Display value
                        Text(String(format: "%.6f", newLongitude))
                            .font(.body)
                            .foregroundColor(Color.blue)  // We color it red to make it stand out.
                        Spacer()
                        // Plus button
                        Button(action: {
                            newLongitude += 0.000001
                            newLongitude = round(1000000 * newLongitude) / 1000000  // Round to 6 decimal places
                        }) {
                            Text("+")
                                .font(.title)
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color.red)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                        }.padding(.trailing, 33)
                        Spacer()
                    }
                    //Spacer()
                }
                                
                // This part is for typing how high up you are.
                HStack {
                    Text("Altitude:")
                        .font(.body)
                        .frame(width: 350, alignment: .leading)
                        .padding(.leading, 2)  // Add 20 points of space to the left
                    
                   // TextField("", value: $newAltitude, formatter:
                    Text(String(newAltitude))                        .font(.body)
                        .foregroundColor(Color.blue)
                }
                
                // This part is for typing how fast you're moving.
                HStack {
                    Text("Speed:")
                        .font(.footnote)
                        .frame(width: 200, alignment: .leading)
                        .padding(.leading, 20)  // Add 20 points of space to the left
                    
                    TextField("", value: $newSpeed, formatter: NumberFormatter())
                        .font(.footnote)
                        .foregroundColor(Color.blue)
                }
                
                // This part is for typing which direction you're facing.
                HStack {
                    Text("Heading:")
                        .font(.footnote)
                        .frame(width: 200, alignment: .leading)
                        .padding(.leading, 20)  // Add 20 points of space to the left
                    
                    TextField("", value: $newHeading, formatter: NumberFormatter())
                        .font(.footnote)
                        .foregroundColor(Color.blue)
                }
                
                // This part is for typing which direction you're moving in.
                HStack {
                    Text("Course:")
                        .font(.footnote)
                        .frame(width: 200, alignment: .leading)
                        .padding(.leading, 20)  // Add 20 points of space to the left
                    
                    TextField("", value: $newCourse, formatter: NumberFormatter())
                        .font(.footnote)
                        .foregroundColor(Color.blue)
                }
                
                // This part is for typing how sure you are about your East/West location.
                HStack {
                    Text("Horiz. Accuracy:")
                        .font(.footnote)
                        .frame(width: 200, alignment: .leading)
                        .padding(.leading, 20)  // Add 20 points of space to the left
                    
                    TextField("", value: $newHorizontalAccuracy, formatter: NumberFormatter())
                        .font(.footnote)
                        .foregroundColor(Color.blue)
                }
                
                // This part is for typing how sure you are about your up/down location.
                HStack {
                    Text("Vert. Accuracy:")
                        .font(.footnote)
                        .frame(width: 200, alignment: .leading)
                        .padding(.leading, 20)  // Add 20 points of space to the left
                    
                    TextField("", value: $newVerticalAccuracy, formatter: NumberFormatter())
                        .font(.footnote)
                        .foregroundColor(Color.blue)
                }
                
                // This part is for typing the air pressure around you.
                HStack {
                    Text("Barometric Pres.:")
                        .font(.footnote)
                        .frame(width: 200, alignment: .leading)
                        .padding(.leading, 20)  // Add 20 points of space to the left
                    
                    TextField("", value: $newBarometricPressure, formatter: NumberFormatter())
                        .font(.footnote)
                }
                
                // This part is for typing how far you've traveled.
                HStack {
                    Text("Distance:")
                        .font(.footnote)
                        .frame(width: 200, alignment: .leading)
                        .padding(.leading, 20)  // Add 20 points of space to the left
                    
                    TextField("", value: $newDistanceTraveled, formatter: NumberFormatter())
                        .font(.footnote)
                }
                
                // This part is for showing the estimated time of arrival.
                
                HStack {
                    // This is the label that says "ETA:"
                    Text("ETA:")
                        .font(.footnote)  // We make the text smaller with "footnote" size.
                        .frame(width: UIScreen.main.bounds.width * 0.4, alignment: .leading)  // We set the frame width to 40% of the screen width and align the text to the leading (left) edge.
                        .padding(.leading, 20)  // Add 20 points of space to the left
                    
                    // This is a spacer that pushes the next element towards the center.
                    Spacer()
                    
                    // This is the text view that shows the time.
                    Text("\(newEstimatedTimeOfArrival, formatter: timeFormatter)")
                        .font(.footnote)  // We make the text smaller with "footnote" size.
                        .frame(width: UIScreen.main.bounds.width * 0.4, alignment: .leading)  // We set the frame width to 40% of the screen width and align the text to the leading (left) edge.
                        .padding(.leading, 40)  // Move the text to the left by the width of approximately one letter.
                    Spacer()
                    
                }
                
                // This part is for typing how close you are to a specific place.
                HStack {
                    Text("Proximity:")
                        .font(.footnote)
                        .frame(width: 200, alignment: .leading)
                        .padding(.leading, 20)  // Add 20 points of space to the left
                    TextField("", value: $newProximityToSpecificLocation, formatter: NumberFormatter())
                        .font(.footnote)
                }
                
                // This part is for typing what kind of GPS point this is.
                HStack {
                    Text("Entry Type:")
                        .font(.footnote)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)  // Use maxWidth: .infinity to push it to the left
                        .padding(.leading, 20)  // Add 20 points of space to the left
 
                    Picker(selection: $newEntryType, label: Text("Select Entry Type")) {
                        Text("Parameter").tag("Parameter").font(.footnote)  // Set the font size here
                        Text("Exclusion").tag("Exclusion").font(.footnote)  // Set the font size here
                        Text("Charging").tag("Charging").font(.footnote)  // Set the font size here
                    }
                    .pickerStyle(MenuPickerStyle())  // Use MenuPickerStyle for a dropdown style
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)  // Use maxWidth: .infinity to push it to the right
                    .padding(.leading,15)
                }

                // This part is for typing the pattern of mowing.
                HStack {
                    Text("Mowing Pattern:")
                        .font(.footnote)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)  // Use maxWidth: .infinity to push it to the left
                        .padding(.leading, 20)  // Add 20 points of space to the left

                    Picker(selection: $newMowingPattern, label: Text("Select Mowing Pattern")) {
                        Text("Lane x Lane").tag("Lane x Lane").font(.footnote)  // Set the font size here
                        Text("Parameter in").tag("Parameter in").font(.footnote)  // Set the font size here
                    }
                    .pickerStyle(MenuPickerStyle())  // Use MenuPickerStyle for a dropdown style
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)  // Use maxWidth: .infinity to push it to the right
                    .padding(.leading,15)
                }

                // This part is for typing the ID of the map you're using.
                HStack {
                    Text("Map ID:")
                        .font(.footnote)
                        .frame(width: 200, alignment: .leading)
                        .padding(.leading, 20)  // Add 20 points of space to the left
                    
                    TextField("", text: $newMapID)
                        .font(.footnote)
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
    
    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium  // This will show the time with seconds.
        return formatter
    }
    
}
