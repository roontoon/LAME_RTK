// Import the necessary libraries for the app
import SwiftUI
import CoreData
import CoreLocation

// The main entry point for the app
@main
struct LAME_RTKApp: App {
    // Create a shared instance of PersistenceController for managing CoreData
    let persistenceController = PersistenceController.shared
    
    // Track the app's lifecycle events
    @Environment(\.scenePhase) var scenePhase
    
    // Include managedObjectContext to interact with CoreData
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    // The main body of the app
    var body: some Scene {
        // Create the main window for the app
        WindowGroup {
            // Initialize ContentView and provide it with the managedObjectContext
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                // Run the checkAndInitializeData function when the app starts
                .onAppear(perform: checkAndInitializeData)
        }
        // Save any changes to CoreData when the app's state changes
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
    
    // Function to check if data exists and initialize it if it doesn't
    func checkAndInitializeData() {
        // Debugging: Print the managed object model
        print("Managed Object Model is \(persistenceController.container.managedObjectModel)")
        
        // Set up the context for CoreData operations
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<GPSDataPoint> = GPSDataPoint.fetchRequest()
        
        do {
            // Try to fetch any existing data
            let existingData = try context.fetch(fetchRequest)
            print("Existing data: \(existingData)")
            
            // If no data exists, initialize it
            if existingData.isEmpty {
                print("Initializing test data")
                initializeTestData(in: context)
            } else {
                print("Data already exists. No need to initialize.")
            }
        } catch {
            // Print an error message if fetching or saving fails
            print("Failed to fetch GPS data points or save context: \(error)")
        }
    }
    
    // Function to initialize test data
    private func initializeTestData(in context: NSManagedObjectContext) {
        // Your existing code for initializing test data goes here
    }
}
