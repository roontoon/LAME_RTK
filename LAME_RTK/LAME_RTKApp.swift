/// We need to import these libraries to use their features.
import SwiftUI
import CoreData
import CoreLocation

@main  /// This tells Swift that our app starts here.
struct LAME_RTKApp: App {
    
    init() {
        // MARK: - Set Light Appearance
        // Force light appearance universally across the application
        UITraitCollection.current = UITraitCollection(userInterfaceStyle: .light)
    }
    
    /// Create a shared instance of our PersistenceController to manage our data.
    //let persistenceController = PersistenceController.shared
    let persistenceController = PersistenceController(inMemory: true)
    
    
    /// This keeps track of what's happening with our app (like if it's active or in the background).
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        // This is the main window of our app.
        WindowGroup {
            // We start with ContentView and give it access to our data.
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear(perform: checkAndInitializeData)  // When the app starts, we run this function.
        }
        // If something changes in our app, we save our data.
        .onChange(of: scenePhase) { newPhase in
            // MARK: - Save Core Data Changes
            // Save any pending Core Data changes.
            if newPhase == .inactive || newPhase == .background {
                persistenceController.save()
            }
            
            // MARK: - Set Light Appearance
            // Force light appearance universally across the application.
            if newPhase == .active {
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
            }
        }
    }
    
    // This function checks if we have data and adds some if we don't.
    func checkAndInitializeData() {
        // We print some info to help us debug.
        print("Managed Object Model is \(persistenceController.container.managedObjectModel)")
        
        // We set up a place to fetch and save data.
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<GPSDataPoint> = GPSDataPoint.fetchRequest()
        
        do {
            // We try to get any existing data.
            let existingData = try context.fetch(fetchRequest)
            print("Existing data: \(existingData)")
            
            // If we don't have any data, we add some.
            if existingData.isEmpty {
                print("Initializing test data")
                //initializeTestData(in: context)
                initializeTestData(in: context, centerCoordinate: CLLocationCoordinate2D(latitude: 28.0699300, longitude: -82.4843600), mapID: "FirstMap")
                initializeTestData(in: context, centerCoordinate: CLLocationCoordinate2D(latitude: 28.0697616, longitude: -82.4844158), mapID: "SecondMap")
                
            } else {
                print("Data already exists. No need to initialize.")
            }
        } catch {
            // If something goes wrong, we print an error message.
            print("Failed to fetch GPS data points or save context: \(error)")
        }
    }
    
    // Adds test data centered around a given coordinate and associates them with a specific mapID.
    private func initializeTestData(in context: NSManagedObjectContext, centerCoordinate: CLLocationCoordinate2D, mapID: String) {
        
        var dataPointCounter = 1  // Initialize counter for dataPointCount field
        
        // Initialize the 6x6 meter square around the center coordinate
        let squareCoordinates = [
            CLLocationCoordinate2D(latitude: centerCoordinate.latitude + 0.000027, longitude: centerCoordinate.longitude + 0.000036),
            CLLocationCoordinate2D(latitude: centerCoordinate.latitude - 0.000027, longitude: centerCoordinate.longitude + 0.000036),
            CLLocationCoordinate2D(latitude: centerCoordinate.latitude - 0.000027, longitude: centerCoordinate.longitude - 0.000036),
            CLLocationCoordinate2D(latitude: centerCoordinate.latitude + 0.000027, longitude: centerCoordinate.longitude - 0.000036)
        ]
        
        // Loop to create a GPSDataPoint for each square coordinate
        for coordinate in squareCoordinates {
            let newPoint = GPSDataPoint(context: context)  // Create new GPSDataPoint
            newPoint.latitude = coordinate.latitude  // Set latitude
            newPoint.longitude = coordinate.longitude  // Set longitude
            newPoint.entryType = "Perimeter"  // Set entry type as 'Perimeter'
            newPoint.mapID = mapID  // Set the map ID
            newPoint.mowingPattern = "Lane x Lane"  // Set mowing pattern
            newPoint.dataPointCount = Int16(dataPointCounter)  // Set data point count
            dataPointCounter += 1  // Increment the counter
        }
        print("Debug: Added Square Coordinates")  // Debug message
        
        // Reset dataPointCounter for the next entryType
        dataPointCounter = 1
        
        // Initialize two 1-meter circles within the 6x6 meter square
        for _ in 1...2 {
            // Randomly generate coordinates for the circle
            let randomLat = Double.random(in: (centerCoordinate.latitude - 0.000027)...(centerCoordinate.latitude + 0.000027))
            let randomLon = Double.random(in: (centerCoordinate.longitude - 0.000036)...(centerCoordinate.longitude + 0.000036))
            let newPoint = GPSDataPoint(context: context)  // Create new GPSDataPoint
            newPoint.latitude = randomLat  // Set latitude
            newPoint.longitude = randomLon  // Set longitude
            newPoint.entryType = "Excluded"  // Set entry type as 'Excluded'
            newPoint.mapID = mapID  // Set the map ID
            newPoint.mowingPattern = "Lane x Lane"  // Set mowing pattern
            newPoint.dataPointCount = Int16(dataPointCounter)  // Set data point count
            dataPointCounter += 1  // Increment the counter
        }
        print("Debug: Added 2 Circles Coordinates")  // Debug message
        
        // Reset dataPointCounter for the next entryType
        dataPointCounter = 1
        
        // Initialize the 1-meter line around the center coordinate
        let lineCoordinates = [
            CLLocationCoordinate2D(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude - 0.000009),
            CLLocationCoordinate2D(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude + 0.000009)
        ]
        
        // Loop to create a GPSDataPoint for each line coordinate
        for coordinate in lineCoordinates {
            let newPoint = GPSDataPoint(context: context)  // Create new GPSDataPoint
            newPoint.latitude = coordinate.latitude  // Set latitude
            newPoint.longitude = coordinate.longitude  // Set longitude
            newPoint.entryType = "Charging"  // Set entry type as 'Charging'
            newPoint.mapID = mapID  // Set the map ID
            newPoint.mowingPattern = "Lane x Lane"  // Set mowing pattern
            newPoint.dataPointCount = Int16(dataPointCounter)  // Set data point count
            dataPointCounter += 1  // Increment the counter
        }
        print("Debug: Added 1 Charging Dock Coordinates")  // Debug message
        
        // Save the context to store all the created data points
        do {
            try context.save()
            print("Test data initialized and saved.")
        } catch {
            print("Failed to save test data: \(error)")
        }
    }
    
}
