//
//  CoreDataManager.swift
//  Lame_RTK
//
//  Created by Roontoon on 9/5/23.


import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    var container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "GPSDataModel")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Error loading Core Data stores: \(error)")
            }
        }
    }
    
    // Save changes to CoreData
    func save() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("Save failed: \(error.localizedDescription)")
            }
        }
    }
    
    // Add a new GPSData
    func addGPSData(data: [String: Any]) {
        let entity = NSEntityDescription.entity(forEntityName: "GPSData", in: container.viewContext)!
        let newPoint = NSManagedObject(entity: entity, insertInto: container.viewContext)
        
        // Set the attributes
        newPoint.setValue(NSDecimalNumber(value: data["latitude"] as! Double), forKey: "latitude")
        newPoint.setValue(NSDecimalNumber(value: data["longitude"] as! Double), forKey: "longitude")
        newPoint.setValue(NSDecimalNumber(value: data["altitude"] as! Double), forKey: "altitude")
        newPoint.setValue(data["timestamp"], forKey: "timestamp")
        newPoint.setValue(NSDecimalNumber(value: data["speed"] as! Double), forKey: "speed")
        newPoint.setValue(NSDecimalNumber(value: data["heading"] as! Double), forKey: "heading")
        newPoint.setValue(NSDecimalNumber(value: data["course"] as! Double), forKey: "course")
        newPoint.setValue(NSDecimalNumber(value: data["horizontalAccuracy"] as! Double), forKey: "horizontalAccuracy")
        newPoint.setValue(NSDecimalNumber(value: data["verticalAccuracy"] as! Double), forKey: "verticalAccuracy")
        newPoint.setValue(NSDecimalNumber(value: data["barometricPressure"] as! Double), forKey: "barometricPressure")
        newPoint.setValue(NSDecimalNumber(value: data["distanceTraveled"] as! Double), forKey: "distanceTraveled")
        newPoint.setValue(data["estimatedTimeOfArrival"], forKey: "estimatedTimeOfArrival")
        newPoint.setValue(NSDecimalNumber(value: data["proximityToSpecificLocation"] as! Double), forKey: "proximityToSpecificLocation")
        newPoint.setValue(data["entryType"], forKey: "entryType")
        newPoint.setValue(data["mowingPattern"], forKey: "mowingPattern")
        newPoint.setValue(data["mapID"], forKey: "mapID")
        
        save()
    }
    
    // Edit an existing GPSData
    func editGPSData(objectID: NSManagedObjectID, newData: [String: Any]) {
        if let object = try? container.viewContext.existingObject(with: objectID) {
            // Update the attributes
            object.setValue(NSDecimalNumber(value: newData["latitude"] as! Double), forKey: "latitude")
            object.setValue(NSDecimalNumber(value: newData["longitude"] as! Double), forKey: "longitude")
            object.setValue(NSDecimalNumber(value: newData["altitude"] as! Double), forKey: "altitude")
            object.setValue(newData["timestamp"], forKey: "timestamp")
            object.setValue(NSDecimalNumber(value: newData["speed"] as! Double), forKey: "speed")
            object.setValue(NSDecimalNumber(value: newData["heading"] as! Double), forKey: "heading")
            object.setValue(NSDecimalNumber(value: newData["course"] as! Double), forKey: "course")
            object.setValue(NSDecimalNumber(value: newData["horizontalAccuracy"] as! Double), forKey: "horizontalAccuracy")
            object.setValue(NSDecimalNumber(value: newData["verticalAccuracy"] as! Double), forKey: "verticalAccuracy")
            object.setValue(NSDecimalNumber(value: newData["barometricPressure"] as! Double), forKey: "barometricPressure")
            object.setValue(NSDecimalNumber(value: newData["distanceTraveled"] as! Double), forKey: "distanceTraveled")
            object.setValue(newData["estimatedTimeOfArrival"], forKey: "estimatedTimeOfArrival")
            object.setValue(NSDecimalNumber(value: newData["proximityToSpecificLocation"] as! Double), forKey: "proximityToSpecificLocation")
            object.setValue(newData["entryType"], forKey: "entryType")
            object.setValue(newData["mowingPattern"], forKey: "mowingPattern")
            object.setValue(newData["mapID"], forKey: "mapID")
            
            save()
        }
    }
    
    // Delete a GPSData
    func deleteGPSData(objectID: NSManagedObjectID) {
        if let object = try? container.viewContext.existingObject(with: objectID) {
            container.viewContext.delete(object)
            save()
        }
    }
    
    // Fetch all GPSData
    func fetchAllGPSData() -> [NSManagedObject]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "GPSData")
        do {
            return try container.viewContext.fetch(request) as? [NSManagedObject]
        } catch {
            print("Fetch failed: \(error.localizedDescription)")
            return nil
        }
    }
}
