// Importing the CoreData framework
import CoreData

// CoreDataManager is a singleton class for managing Core Data operations.
class CoreDataManager {
    // Singleton instance of CoreDataManager
    static let shared = CoreDataManager()
    
    // Persistent container for Core Data
    var container: NSPersistentContainer
    
    // Initializes the Core Data manager and loads the persistent stores.
    init() {
        container = NSPersistentContainer(name: "GPSDataModel")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                // Handle error during the loading of Core Data stores
                fatalError("Error loading Core Data stores: \(error)")
            }
        }
    }
    
    // Saves changes to Core Data if there are any.
    func save() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                // Log the error if saving fails
                print("Save failed: \(error.localizedDescription)")
            }
        }
    }
    
    // Adds a new GPSData entity to Core Data.
    // - Parameter data: Dictionary containing the GPS data attributes.
    func addGPSData(data: [String: Any]) {
        let entity = NSEntityDescription.entity(forEntityName: "GPSData", in: container.viewContext)!
        let newPoint = NSManagedObject(entity: entity, insertInto: container.viewContext)
        
        // Set the attributes safely using optional casting
        newPoint.setValue(NSDecimalNumber(value: data["latitude"] as? Double ?? 0.0), forKey: "latitude")
        newPoint.setValue(NSDecimalNumber(value: data["longitude"] as? Double ?? 0.0), forKey: "longitude")
        newPoint.setValue(NSDecimalNumber(value: data["altitude"] as? Double ?? 0.0), forKey: "altitude")
        newPoint.setValue(data["timestamp"], forKey: "timestamp")
        newPoint.setValue(NSDecimalNumber(value: data["speed"] as? Double ?? 0.0), forKey: "speed")
        newPoint.setValue(NSDecimalNumber(value: data["heading"] as? Double ?? 0.0), forKey: "heading")
        newPoint.setValue(NSDecimalNumber(value: data["course"] as? Double ?? 0.0), forKey: "course")
        newPoint.setValue(NSDecimalNumber(value: data["horizontalAccuracy"] as? Double ?? 0.0), forKey: "horizontalAccuracy")
        newPoint.setValue(NSDecimalNumber(value: data["verticalAccuracy"] as? Double ?? 0.0), forKey: "verticalAccuracy")
        newPoint.setValue(NSDecimalNumber(value: data["barometricPressure"] as? Double ?? 0.0), forKey: "barometricPressure")
        newPoint.setValue(NSDecimalNumber(value: data["distanceTraveled"] as? Double ?? 0.0), forKey: "distanceTraveled")
        newPoint.setValue(data["estimatedTimeOfArrival"], forKey: "estimatedTimeOfArrival")
        newPoint.setValue(NSDecimalNumber(value: data["proximityToSpecificLocation"] as? Double ?? 0.0), forKey: "proximityToSpecificLocation")
        newPoint.setValue(data["entryType"], forKey: "entryType")
        newPoint.setValue(data["mowingPattern"], forKey: "mowingPattern")
        newPoint.setValue(data["mapID"], forKey: "mapID")
        
        save()
    }
    
    // Edits an existing GPSData entity in Core Data.
    // - Parameters:
    //   - objectID: The object ID of the GPSData entity to edit.
    //   - newData: Dictionary containing the new GPS data attributes.
    func editGPSData(objectID: NSManagedObjectID, newData: [String: Any]) {
        if let object = try? container.viewContext.existingObject(with: objectID) {
            // Update the attributes safely using optional casting
            object.setValue(NSDecimalNumber(value: newData["latitude"] as? Double ?? 0.0), forKey: "latitude")
            object.setValue(NSDecimalNumber(value: newData["longitude"] as? Double ?? 0.0), forKey: "longitude")
            object.setValue(NSDecimalNumber(value: newData["altitude"] as? Double ?? 0.0), forKey: "altitude")
            object.setValue(newData["timestamp"], forKey: "timestamp")
            object.setValue(NSDecimalNumber(value: newData["speed"] as? Double ?? 0.0), forKey: "speed")
            object.setValue(NSDecimalNumber(value: newData["heading"] as? Double ?? 0.0), forKey: "heading")
            object.setValue(NSDecimalNumber(value: newData["course"] as? Double ?? 0.0), forKey: "course")
            object.setValue(NSDecimalNumber(value: newData["horizontalAccuracy"] as? Double ?? 0.0), forKey: "horizontalAccuracy")
            object.setValue(NSDecimalNumber(value: newData["verticalAccuracy"] as? Double ?? 0.0), forKey: "verticalAccuracy")
            object.setValue(NSDecimalNumber(value: newData["barometricPressure"] as? Double ?? 0.0), forKey: "barometricPressure")
            object.setValue(NSDecimalNumber(value: newData["distanceTraveled"] as? Double ?? 0.0), forKey: "distanceTraveled")
            object.setValue(newData["estimatedTimeOfArrival"], forKey: "estimatedTimeOfArrival")
            object.setValue(NSDecimalNumber(value: newData["proximityToSpecificLocation"] as? Double ?? 0.0), forKey: "proximityToSpecificLocation")
            object.setValue(newData["entryType"], forKey: "entryType")
            object.setValue(newData["mowingPattern"], forKey: "mowingPattern")
            object.setValue(newData["mapID"], forKey: "mapID")
            
            save()
        }
    }
    
    // Deletes a GPSData entity from Core Data.
    // - Parameter objectID: The object ID of the GPSData entity to delete.
    func deleteGPSData(objectID: NSManagedObjectID) {
        if let object = try? container.viewContext.existingObject(with: objectID) {
            container.viewContext.delete(object)
            save()
        }
    }
    
    // Fetches all GPSData entities from Core Data.
    // - Returns: An array of NSManagedObject instances representing the GPSData entities, or nil if fetch fails.
    func fetchAllGPSData() -> [NSManagedObject]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "GPSData")
        do {
            return try container.viewContext.fetch(request) as? [NSManagedObject]
        } catch {
            // Log the error if fetching fails
            print("Fetch failed: \(error.localizedDescription)")
            return nil
        }
    }
}
