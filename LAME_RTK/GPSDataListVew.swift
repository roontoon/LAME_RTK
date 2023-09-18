// Importing SwiftUI and CoreData to utilize their features
import SwiftUI
import CoreData

// ItemDetailView struct serves as a detailed view for each GPSDataPoint
struct GPSDataListView: View {
    // Accessing the CoreData storage to save and fetch data
    @Environment(\.managedObjectContext) private var viewContext
    
    // ObservedObject allows us to monitor changes in the GPSDataPoint
    @ObservedObject var gpsDataPoint: GPSDataPoint
    
    // State variables to hold new values for updating the GPSDataPoint
    @State private var newTimestamp: Date
    @State private var newLongitude: Double
    @State private var newLatitude: Double
    
    // Initializer to set up the view with the current GPSDataPoint
    init(gpsDataPoint: GPSDataPoint) {
        self.gpsDataPoint = gpsDataPoint
        // Initializing state variables with current values
        self._newTimestamp = State(initialValue: gpsDataPoint.timestamp ?? Date())
        self._newLongitude = State(initialValue: gpsDataPoint.longitude)
        self._newLatitude = State(initialValue: gpsDataPoint.latitude)
    }
    
    // Main body of the ItemDetailView
    var body: some View {
        // Form layout for user input
        Form {
            // DatePicker for selecting a new timestamp
            DatePicker("Timestamp", selection: $newTimestamp, displayedComponents: .date)
                .accentColor(Color.purple)  // Custom accent color
            
            // TextField for entering a new longitude value
            TextField("Longitude", value: $newLongitude, formatter: GPSFormatter())
                .foregroundColor(Color.red)  // Custom text color
            
            // TextField for entering a new latitude value
            TextField("Latitude", value: $newLatitude, formatter: GPSFormatter())
                .foregroundColor(Color.green)  // Custom text color
        }
        // Save button on the navigation bar
        .navigationBarItems(trailing: Button("Save") {
            // Save action
            saveChanges()
        })
        .accentColor(Color.purple)  // Global accent color
    }
    
    // Function to save changes to the GPSDataPoint
    private func saveChanges() {
        // Animation for smooth UI transitions
        withAnimation {
            // Updating the GPSDataPoint with new values
            gpsDataPoint.timestamp = newTimestamp
            gpsDataPoint.latitude = newLatitude
            gpsDataPoint.longitude = newLongitude
            
            // Attempting to save changes to CoreData
            do {
                try viewContext.save()
            } catch {
                // Error handling
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // NumberFormatter for GPS coordinates
    func GPSFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 8  // Up to 8 decimal places
        formatter.minimumFractionDigits = 8  // At least 8 decimal places
        return formatter
    }
}

