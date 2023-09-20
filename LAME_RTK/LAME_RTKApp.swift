// We need to import these libraries to use their features.
import SwiftUI
import CoreData
import CoreLocation

@main  // This tells Swift that our app starts here.
struct LAME_RTKApp: App {
    // We create a shared instance of our PersistenceController to manage our data.
    let persistenceController = PersistenceController.shared
    
    // This keeps track of what's happening with our app (like if it's active or in the background).
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
        // We set up some coordinates for our test data.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 28.06993, longitude: -82.48436)
        let squareCoordinates = [
            CLLocationCoordinate2D(latitude: centerCoordinate.latitude + 0.000027, longitude: centerCoordinate.longitude + 0.000036),
            CLLocationCoordinate2D(latitude: centerCoordinate.latitude - 0.000027, longitude: centerCoordinate.longitude + 0.000036),
            CLLocationCoordinate2D(latitude: centerCoordinate.latitude - 0.000027, longitude: centerCoordinate.longitude - 0.000036),
            CLLocationCoordinate2D(latitude: centerCoordinate.latitude + 0.000027, longitude: centerCoordinate.longitude - 0.000036)
        ]
        
        // We add the test data to our database.
        for coordinate in squareCoordinates {
            let newPoint = GPSDataPoint(context: context)
            newPoint.latitude = coordinate.latitude
            newPoint.longitude = coordinate.longitude
            newPoint.entryType = "Perimeter"
            newPoint.mapID = "TestData"
        }
        
        // We save our changes.
        do {
            try context.save()
            print("Test data initialized and saved.")
        } catch {
            // If something goes wrong, we print an error message.
            print("Failed to save test data: \(error)")
        }
    }
}
