/// We need to import these libraries to use their features.
import SwiftUI
import CoreData
import CoreLocation

@main  /// This tells Swift that our app starts here.
struct LAME_RTKApp: App {
    /// Create a shared instance of our PersistenceController to manage our data.
    let persistenceController = PersistenceController.shared
    
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
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
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
                initializeTestData(in: context)
            } else {
                print("Data already exists. No need to initialize.")
            }
        } catch {
            // If something goes wrong, we print an error message.
            print("Failed to fetch GPS data points or save context: \(error)")
        }
    }
    
    // This function adds some test data.
    private func initializeTestData(in context: NSManagedObjectContext) {

        // Initialize the 6x6 meter square
        let centerCoordinate = CLLocationCoordinate2D(latitude: 28.0699300, longitude: -82.4843600)
        let squareCoordinates = [
            CLLocationCoordinate2D(latitude: centerCoordinate.latitude + 0.000027, longitude: centerCoordinate.longitude + 0.000036),
            CLLocationCoordinate2D(latitude: centerCoordinate.latitude - 0.000027, longitude: centerCoordinate.longitude + 0.000036),
            CLLocationCoordinate2D(latitude: centerCoordinate.latitude - 0.000027, longitude: centerCoordinate.longitude - 0.000036),
            CLLocationCoordinate2D(latitude: centerCoordinate.latitude + 0.000027, longitude: centerCoordinate.longitude - 0.000036)
        ]
        
        for coordinate in squareCoordinates {
            let newPoint = GPSDataPoint(context: context)
            newPoint.latitude = coordinate.latitude
            newPoint.longitude = coordinate.longitude
            newPoint.entryType = "Perimeter"
            newPoint.mapID = "TestData"
            newPoint.mowingPattern = "Lane x Lane"
        }
        print("Debug: Added Square Coordinates")
        
        // Initialize the two 1-meter circles
        // Randomly generate the coordinates for the circles within the 6x6 meter square
        for _ in 1...2 {
            let randomLat = Double.random(in: (centerCoordinate.latitude - 0.000027)...(centerCoordinate.latitude + 0.000027))
            let randomLon = Double.random(in: (centerCoordinate.longitude - 0.000036)...(centerCoordinate.longitude + 0.000036))
            let newPoint = GPSDataPoint(context: context)
            newPoint.latitude = randomLat
            newPoint.longitude = randomLon
            newPoint.entryType = "Excluded"
            newPoint.mapID = "TestData"
            newPoint.mowingPattern = "Lane x Lane"

        }
        print("Debug: Added 2 Circles Coordinates")
        
        // Initialize the 1-meter line
        let lineStart = CLLocationCoordinate2D(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude - 0.000009)
        let lineEnd = CLLocationCoordinate2D(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude + 0.000009)
        
        let newPointStart = GPSDataPoint(context: context)
        newPointStart.latitude = lineStart.latitude
        newPointStart.longitude = lineStart.longitude
        newPointStart.entryType = "Charging"
        newPointStart.mowingPattern = "Lane x Lane"
        newPointStart.mapID = "TestData"
        
        let newPointEnd = GPSDataPoint(context: context)
        newPointEnd.latitude = lineEnd.latitude
        newPointEnd.longitude = lineEnd.longitude
        newPointEnd.entryType = "Charging"
        newPointEnd.mowingPattern = "Lane x Lane"
        newPointEnd.mapID = "TestData"
        
        print("Debug: Added 1 Charging Dock Coordinates")
        
        do {
            try context.save()
            print("Test data initialized and saved.")
        } catch {
            print("Failed to save test data: \(error)")
        }
    }
}
