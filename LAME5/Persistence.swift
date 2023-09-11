//
//  Persistence.swift
//  Lame_RTK
//
//  Created by Roontoon on 9/5/23.
//
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newPoint = GPSDataPoint(context: viewContext)
            newPoint.timestamp = Date()
            newPoint.latitude = 0.0
            newPoint.longitude = 0.0
            newPoint.altitude = 0.0
            newPoint.speed = 0.0
            newPoint.heading = 0.0
            newPoint.course = 0.0
            newPoint.horizontalAccuracy = 0.0
            newPoint.verticalAccuracy = 0.0
            newPoint.barometricPressure = 0.0
            newPoint.distanceTraveled = 0.0
            newPoint.estimatedTimeOfArrival = Date()
            newPoint.proximityToSpecificLocation = 0.0
            newPoint.entryType = ""
            newPoint.mowingPattern = ""
            newPoint.mapID = ""
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "GPSDataModel")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
