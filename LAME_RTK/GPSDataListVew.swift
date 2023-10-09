///
///  GPSDataListView.swift
///  YourProjectName
///
///  Created by Your Name on Date.
///  Last documented on October 9, 2023.
///
///  Description: This SwiftUI view is designed to display and edit a single GPS data point.
///               It includes various state variables for holding temporary edits.
///

/// MARK: - Import Statements
/// Importing the SwiftUI and CoreData frameworks to build the interface and manage data.
import SwiftUI
import CoreData

/// MARK: - GPSDataListView Struct
/// This is a screen that shows details about a GPS data point.
struct GPSDataListView: View {
    /// MARK: Environment and Observed Object
    /// This helps us talk to the place where the GPS data is stored.
    @Environment(\.managedObjectContext) private var viewContext
    
    /// This keeps track of a single GPS data point and any changes to it.
    @ObservedObject var gpsDataPoint: GPSDataPoint
    
    /// MARK: State Variables
    /// These are boxes to hold new information that we might want to save.
    @State private var newTimestamp: Date  /// For the date and time
    @State private var newLongitude: Double  /// For how far East or West
    @State private var newLatitude: Double  /// For how far North or South
    @State private var newAltitude: Double  /// For how high up
    @State private var newSpeed: Double  /// For how fast moving
    @State private var newHeading: Double  /// For which direction facing
    @State private var newCourse: Double  /// For which direction moving
    @State private var newHorizontalAccuracy: Double  /// For how sure we are about East/West location
    @State private var newVerticalAccuracy: Double  /// For how sure we are about up/down location
    @State private var newBarometricPressure: Double  /// For the air pressure
    @State private var newDistanceTraveled: Double  /// For how far traveled
    @State private var newEstimatedTimeOfArrival: Date  /// For when we'll get there
    @State private var newProximityToSpecificLocation: Double  /// For how close we are to a specific place
    @State private var newEntryType: String  /// For the type of GPS point
    @State private var newMowingPattern: String  /// For the pattern of mowing
    @State private var newMapID: String  /// For the ID of the map
    /// MARK: - Initialization
    /// This sets up the screen with the current GPS data point.
    init(gpsDataPoint: GPSDataPoint) {
        self.gpsDataPoint = gpsDataPoint
        /// We start the boxes with the current information.
        self._newTimestamp = State(initialValue: gpsDataPoint.timestamp ?? Date())
        self._newLongitude = State(initialValue: gpsDataPoint.longitude)
        self._newLatitude = State(initialValue: gpsDataPoint.latitude)
        /// We also start the other boxes with some default information.
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
    /// MARK: - Body Property
    /// This is the main part of our screen.
    var body: some View {
        /// We're making a scrollable area so you can see everything, even if it's a lot!
        ScrollView {
            /// A vertical stack to organize the elements in a top-to-bottom manner
            VStack(alignment: .leading) {
                
                /// MARK: - Latitude UI Components
                /// The UI section for displaying and editing Latitude
                HStack {
                    Text("Latitude:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    HStack {
                        /// Latitude Minus button to decrease the latitude value
                        Button(action: {
                            newLatitude -= 0.000001
                            newLatitude = round(1000000 * newLatitude) / 1000000  /// Round to 6 decimal places
                        }) {
                            Text("-")
                                .font(.callout)
                                .frame(width: 15, height: 15)
                                .foregroundColor(Color.red)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                        }
                        
                        /// Display Latitude value
                        Text(String(format: "%.6f", newLatitude))
                            .font(.callout)
                            .foregroundColor(Color.green)
                        
                        /// Latitude Plus button to increase the latitude value
                        Button(action: {
                            newLatitude += 0.000001
                            newLatitude = round(1000000 * newLatitude) / 1000000  /// Round to 6 decimal places
                        }) {
                            Text("+")
                                .font(.callout)
                                .frame(width: 15, height: 15)
                                .foregroundColor(Color.green)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                    .frame(width: 2 * UIScreen.main.bounds.width / 3, alignment: .leading)
                }

                /// MARK: - Longitude UI Components
                /// The UI section for displaying and editing Longitude
                HStack {
                    Text("Longitude:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    HStack {
                        /// Minus button to decrease the longitude value
                        Button(action: {
                            newLongitude -= 0.000001
                            newLongitude = round(1000000 * newLongitude) / 1000000  /// Round to 6 decimal places
                        }) {
                            Text("-")
                                .font(.callout)
                                .frame(width: 15, height: 15)
                                .foregroundColor(Color.red)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                        }

                        /// Display Longitude value
                        Text(String(format: "%.6f", newLongitude))
                            .font(.callout)
                            .foregroundColor(Color.red)
                        
                        /// Plus button to increase the longitude value
                        Button(action: {
                            newLongitude += 0.000001
                            newLongitude = round(1000000 * newLongitude) / 1000000  /// Round to 6 decimal places
                        }) {
                            Text("+")
                                .font(.callout)
                                .frame(width: 15, height: 15)
                                .foregroundColor(Color.green)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                    .frame(width: 2 * UIScreen.main.bounds.width / 3, alignment: .leading)
                }
                /// MARK: - Altitude UI Components
                /// The UI section for displaying Altitude
                HStack {
                    Text("Altitude:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    Text(String(newAltitude))
                        .frame(width: 2 * UIScreen.main.bounds.width / 3)
                }
                
                /// MARK: - Speed UI Components
                /// The UI section for displaying Speed
                HStack {
                    Text("Speed:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    Text(String(newSpeed))
                        .frame(width: 2 * UIScreen.main.bounds.width / 3)
                }
                
                /// MARK: - Heading UI Components
                /// The UI section for displaying Heading
                HStack {
                    Text("Heading:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    Text(String(newHeading))
                        .frame(width: 2 * UIScreen.main.bounds.width / 3)
                }

                /// MARK: - Course UI Components
                /// The UI section for displaying Course
                HStack {
                    Text("Course:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    Text(String(newCourse))
                        .frame(width: 2 * UIScreen.main.bounds.width / 3)
                }
                
                /// MARK: - Horizontal Accuracy UI Components
                /// The UI section for displaying Horizontal Accuracy
                HStack {
                    Text("Horiz. Accuracy:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    Text(String(newHorizontalAccuracy))
                        .frame(width: 2 * UIScreen.main.bounds.width / 3)
                }

                /// MARK: - Vertical Accuracy UI Components
                /// The UI section for displaying Vertical Accuracy
                HStack {
                    Text("Vert. Accuracy:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    Text(String(newVerticalAccuracy))
                        .frame(width: 2 * UIScreen.main.bounds.width / 3)
                }
                /// MARK: - Additional GPS Data UI Components
                /// The UI sections for displaying other GPS data like Barometric Pressure, Distance, and Proximity
                HStack {
                    Text("Barometric Pres.:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    Text(String(newHorizontalAccuracy))
                        .frame(width: 2 * UIScreen.main.bounds.width / 3)
                }
                
                HStack {
                    Text("Distance:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    Text(String(newBarometricPressure))
                        .frame(width: 2 * UIScreen.main.bounds.width / 3)
                }
                
                HStack {
                    Text("Proximity:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    Text(String(newProximityToSpecificLocation))
                        .frame(width: 2 * UIScreen.main.bounds.width / 3)
                }
                
                HStack {
                    Text("ETA:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    Text("\(newEstimatedTimeOfArrival, formatter: timeFormatter)")
                        .padding(.leading, 50)
                }

                /// MARK: - Picker UI Components for Entry Type, Mowing Pattern, and Map ID
                /// The UI sections for selecting Entry Type, Mowing Pattern, and Map ID
                HStack {
                    Text("Entry Type:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    Picker(selection: $newEntryType, label: Text("Select Entry Type")) {
                        Text("Parameter").tag("Parameter").font(.footnote)
                        Text("Exclusion").tag("Exclusion").font(.footnote)
                        Text("Charging").tag("Charging").font(.footnote)
                    }.pickerStyle(MenuPickerStyle())
                        .frame(width: 2 * UIScreen.main.bounds.width / 3, alignment: .leading)
                }
                
                HStack {
                    Text("Mowing Pattern:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    Picker(selection: $newMowingPattern, label: Text("Select Entry Type")) {
                        Text("Parameter").tag("Parameter").font(.footnote)
                        Text("Lane").tag("Lane").font(.footnote)
                    }.pickerStyle(MenuPickerStyle())
                        .frame(width: 2 * UIScreen.main.bounds.width / 3, alignment: .leading)
                }

                HStack {
                    Text("Map ID:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    Picker(selection: $newMapID, label: Text("Select Map")) {
                        Text("TestData1").tag("TestData1").font(.footnote)
                        Text("TestData2").tag("TestData2").font(.footnote)
                    }.pickerStyle(MenuPickerStyle())
                        .frame(width: 2 * UIScreen.main.bounds.width / 3, alignment: .leading)
                }
            }.padding(5)
        }

        /// We add a Save button to keep our changes.
        .navigationBarItems(trailing: Button("Save") {
            /// When we press Save, this happens.
            saveChanges()
        })
        .accentColor(Color.purple)  /// We make other things purple too!
    }
    /// MARK: - Save Changes Function
    /// This function is responsible for saving the edited GPS data.
    private func saveChanges() {
        /// Smooth animation for visual feedback
        withAnimation {
            /// Updating the GPSDataPoint object with new values
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
            
            /// Attempt to save the changes to Core Data
            do {
                try viewContext.save()
            } catch {
                /// Handle the error
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    /// MARK: - Utility Functions
    
    /// Function to format GPS numbers for display
    func GPSFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 6
        formatter.minimumFractionDigits = 6
        return formatter
    }
    
    /// Function to format time for display
    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }
}

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
/*/// We're using tools from SwiftUI and CoreData to make our app.
import SwiftUI
import CoreData

/// This is a screen that shows details about a GPS data point.
struct GPSDataListView: View {
    /// This helps us talk to the place where the GPS data is stored.
    @Environment(\.managedObjectContext) private var viewContext
    
    /// This keeps track of a single GPS data point and any changes to it.
    @ObservedObject var gpsDataPoint: GPSDataPoint
    
    /// These are boxes to hold new information that we might want to save.
    @State private var newTimestamp: Date  /// For the date and time
    @State private var newLongitude: Double  /// For how far East or West
    @State private var newLatitude: Double  /// For how far North or South
    @State private var newAltitude: Double  /// For how high up
    @State private var newSpeed: Double  /// For how fast moving
    @State private var newHeading: Double  /// For which direction facing
    @State private var newCourse: Double  /// For which direction moving
    @State private var newHorizontalAccuracy: Double  /// For how sure we are about East/West location
    @State private var newVerticalAccuracy: Double  /// For how sure we are about up/down location
    @State private var newBarometricPressure: Double  /// For the air pressure
    @State private var newDistanceTraveled: Double  /// For how far traveled
    @State private var newEstimatedTimeOfArrival: Date  /// For when we'll get there
    @State private var newProximityToSpecificLocation: Double  /// For how close we are to a specific place
    @State private var newEntryType: String  /// For the type of GPS point
    @State private var newMowingPattern: String  /// For the pattern of mowing
    @State private var newMapID: String  /// For the ID of the map
    
    /// This sets up the screen with the current GPS data point.
    init(gpsDataPoint: GPSDataPoint) {
        self.gpsDataPoint = gpsDataPoint
        /// We start the boxes with the current information.
        self._newTimestamp = State(initialValue: gpsDataPoint.timestamp ?? Date())
        self._newLongitude = State(initialValue: gpsDataPoint.longitude)
        self._newLatitude = State(initialValue: gpsDataPoint.latitude)
        /// We also start the other boxes with some default information.
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
    
     var body: some View {
        
        /// We're making a scrollable area so you can see everything, even if it's a lot!
        ScrollView {
            
            VStack(alignment: .leading) {
                
                HStack {
                    Text("Latitude:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    ///.border(Color.black)
                    HStack{
                        /// Latitude Minus button
                        Button(action: {
                            newLatitude -= 0.000001
                            newLatitude = round(1000000 * newLatitude) / 1000000  /// Round to 6 decimal places
                        }) {
                            Text("-")
                                .font(.callout)
                                .frame(width: 15, height: 15)
                                .foregroundColor(Color.red)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                        }
                        
                        /// Display Latitude value
                        Text("")
                        Text(String(format: "%.6f", newLatitude))
                            .font(.callout)
                            .foregroundColor(Color.green)  /// We color it red to make it stand out.
                        
                        /// Plus button
                        Button(action: {
                            newLatitude += 0.000001
                            newLatitude = round(1000000 * newLatitude) / 1000000  /// Round to 6 decimal places
                        }) {
                            Text("+")
                                .font(.callout)
                                .frame(width: 15, height: 15)
                                .foregroundColor(Color.green)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                        }
                        ///.padding(.trailing, 33)
                    }
                    .frame(width: 2 * UIScreen.main.bounds.width / 3, alignment: .leading)
                    ///.border(Color.black)
                }
                
                
                HStack {
                    Text("Longitude:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    ///.border(Color.black)
                    HStack {
                        /// Minus button
                        Button(action: {
                            newLongitude -= 0.000001
                            newLongitude = round(1000000 * newLongitude) / 1000000  /// Round to 6 decimal places
                        }) {
                            Text("-")
                                .font(.callout)
                                .frame(width: 15, height: 15)
                                .foregroundColor(Color.red)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                        }
                        
                        
                        /// Display value
                        Text(String(format: "%.6f", newLongitude))
                            .font(.callout)
                            .foregroundColor(Color.red)  /// We color it red to make it stand out.
                        
                        
                        /// Plus button
                        Button(action: {
                            newLongitude += 0.000001
                            newLongitude = round(1000000 * newLongitude) / 1000000  /// Round to 6 decimal places
                        }) {
                            Text("+")
                                .font(.callout)
                                .frame(width: 15, height: 15)
                                .foregroundColor(Color.green)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                        }///.padding(.trailing, 33)
                    }
                    .frame(width: 2 * UIScreen.main.bounds.width / 3, alignment: .leading)
                    ///.border(Color.black)
                }
                
                HStack {
                    Text("Altitude:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    ///.border(Color.black)
                    Text(String(newAltitude))
                        .frame(width: 2 * UIScreen.main.bounds.width / 3)
                    ///.border(Color.black)
                }
                
                
                HStack {
                    Text("Speed:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    ///.border(Color.black)
                    Text(String(newSpeed))
                        .frame(width: 2 * UIScreen.main.bounds.width / 3)
                        ///.padding(.leading, 38)
                    ///.border(Color.black)
                }
                
                
                HStack {
                    Text("Heading:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    ///.border(Color.black)
                    Text(String(newHeading))
                        .frame(width: 2 * UIScreen.main.bounds.width / 3)
                        ///.padding(.leading, 38)
                    ///.border(Color.black)
                }
                
                
                HStack {
                    Text("Course:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    ///.border(Color.black)
                    Text(String(newCourse))
                        .frame(width: 2 * UIScreen.main.bounds.width / 3)
                        ///.padding(.leading, 38)
                    ///.border(Color.black)
                }
                
                
                HStack {
                    Text("Horiz. Accuracy:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    ///.border(Color.black)
                    Text(String(newHorizontalAccuracy))
                        .frame(width: 2 * UIScreen.main.bounds.width / 3)
                        ///.padding(.leading, 38)
                    ///.border(Color.black)
                }
                
                
                HStack {
                    Text("Vert. Accuracy:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    ///.border(Color.black)
                    Text(String(newVerticalAccuracy))
                        .frame(width: 2 * UIScreen.main.bounds.width / 3)
                        ///.padding(.leading, 38)
                    ///.border(Color.black)
                }
                
                
                HStack {
                    Text("Barometric Pres.:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    ///.border(Color.black)
                    Text(String(newHorizontalAccuracy))
                        .frame(width: 2 * UIScreen.main.bounds.width / 3)
                        ///.padding(.leading, 38)
                    ///.border(Color.black)
                }
                
                
                HStack {
                    Text("Distance:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    ///.border(Color.black)
                    Text(String(newBarometricPressure))
                        .frame(width: 2 * UIScreen.main.bounds.width / 3)
                        ///.padding(.leading, 38)
                    ///.border(Color.black)
                }
                
                
                HStack {
                    Text("Proximity:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    ///.border(Color.black)
                    Text(String(newProximityToSpecificLocation))
                        .frame(width: 2 * UIScreen.main.bounds.width / 3)
                        ///.padding(.leading, 38)
                    ///.border(Color.black)
                }
                
                
                HStack{
                    Text("ETA:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    Text("\(newEstimatedTimeOfArrival, formatter: timeFormatter)")
                        .padding(.leading, 50)
                    ///.border(Color.black)
                }
                

                HStack {
                    Text("Entry Type:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    ///Text(String(newEntryType))
                    Picker(selection: $newEntryType, label: Text("Select Entry Type")) {
                        Text("Parameter").tag("Parameter").font(.footnote)  /// Set the font size here
                        Text("Exclusion").tag("Exclusion").font(.footnote)  /// Set the font size here
                        Text("Charging").tag("Charging").font(.footnote)  /// Set the font size here
                    }.pickerStyle(MenuPickerStyle())  /// Use MenuPickerStyle for a dropdown style
                        .frame(width: 2 * UIScreen.main.bounds.width / 3, alignment: .leading)
                     
                }
                
                
                HStack {
                    Text("Mowing Pattern:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    ///Text(String(newMowing))
                    Picker(selection: $newMowingPattern, label: Text("Select Entry Type")) {
                        Text("Parameter").tag("Parameter").font(.footnote)  /// Set the font size here
                        Text("Lane").tag("Lane").font(.footnote)  /// Set the font size here
                    }.pickerStyle(MenuPickerStyle())  /// Use MenuPickerStyle for a dropdown style
                        .frame(width: 2 * UIScreen.main.bounds.width / 3, alignment: .leading)
                 }

                
                HStack {
                    Text("Map ID:")
                        .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
                        .padding(.leading, 30)
                    ///Text(String(newMapID))
                    Picker(selection: $newMapID, label: Text("Select Map")) {
                        Text("TestData1").tag("TestData1").font(.footnote)  /// Set the font size here
                        Text("TestData2").tag("TestData2").font(.footnote)  /// Set the font size here
                    }.pickerStyle(MenuPickerStyle())  /// Use MenuPickerStyle for a dropdown style
                        .frame(width: 2 * UIScreen.main.bounds.width / 3, alignment: .leading)
                 }
            }.padding(5)
            
            
            
            
        }
        
        /// We add a Save button to keep our changes.
        .navigationBarItems(trailing: Button("Save") {
            /// When we press Save, this happens.
            saveChanges()
        })
        .accentColor(Color.purple)  /// We make other things purple too!
    }
    
    /// This is how we save our changes.
    private func saveChanges() {
        /// We make the changes look smooth.
        withAnimation {
            /// We update the GPS data point with our new information.
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
            
            /// We try to save our changes.
            do {
                try viewContext.save()
            } catch {
                /// If something goes wrong, we show an error.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    /// This makes sure our numbers look right.
    func GPSFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal  /// We want decimal numbers.
        formatter.maximumFractionDigits = 6  /// Up to 8 numbers after the dot.
        formatter.minimumFractionDigits = 6  /// At least 8 numbers after the dot.
        return formatter
    }
    
    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium  /// This will show the time with seconds.
        return formatter
    }
    
}
*/
