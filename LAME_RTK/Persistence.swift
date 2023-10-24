// Importing the CoreData framework to use its features.
import CoreData

// Defining a struct called PersistenceController.
struct PersistenceController {
    
    // A static instance of PersistenceController for the entire app to use.
    static let shared = PersistenceController()
    
    // A static variable for previewing the Core Data setup.
    static var preview: PersistenceController = {
        // Creating an instance of PersistenceController with in-memory storage.
        let result = PersistenceController(inMemory: true)
        
        // Getting the viewContext from the NSPersistentContainer.
        let viewContext = result.container.viewContext
        
        // Creating 10 new GPSDataPoint objects and saving them in viewContext.
        for _ in 0..<10 {
            let newItem = GPSDataPoint(context: viewContext)
            newItem.timestamp = Date()
            newItem.latitude  = 0
            newItem.longitude = 0
        }
        
        // Attempting to save changes to viewContext.
        do {
            try viewContext.save()
        } catch {
            // Handling errors during save.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        // Returning the configured PersistenceController.
        return result
    }()
    
    // An NSPersistentContainer for Core Data storage.
    let container: NSPersistentContainer
    
    // Initializer for PersistenceController.
    init(inMemory: Bool = false) {
        // Initializing NSPersistentContainer with the model name "GPSDataModel".
        container = NSPersistentContainer(name: "GPSDataModel")
        
        // If inMemory is true, use in-memory storage.
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Loading the persistent stores.
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            // Handling errors during loading.
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        // Enabling automatic merging of changes.
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // Function to save changes to the viewContext.
    func save() {
        let result = container.viewContext
        if result.hasChanges {
            do {
                try result.save()
            } catch {
                // Handle errors here.
            }
        }
    }
}

