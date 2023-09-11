//  Lame_RTK
//
//  Created by Roontoon on 9/5/23.
//
import CoreData
import CoreLocation

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "GPSDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }

    func checkAndInitializeData() {
        print("Managed Object Model is \(self.container.managedObjectModel)")
        
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<GPSDataPoint> = GPSDataPoint.fetchRequest()
        
        do {
            let existingData = try context.fetch(fetchRequest)
            print("Existing data: \(existingData)")
            
            let count = existingData.count
            if count == 0 {
                print("Initializing test data")
                initializeTestData(in: context)
            } else {
                print("Data already exists. No need to initialize.")
            }
        } catch {
            print("Failed to fetch GPS data points or save context: \(error)")
        }
    }
    
    private func initializeTestData(in context: NSManagedObjectContext) {
        // Initialize the 6x6 meter square
        let centerCoordinate = CLLocationCoordinate2D(latitude: 28.06993, longitude: -82.48436)
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
        }
        
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
        }
        
        // Initialize the 1-meter line
        let lineStart = CLLocationCoordinate2D(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude - 0.000009)
        let lineEnd = CLLocationCoordinate2D(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude + 0.000009)
        
        let newPointStart = GPSDataPoint(context: context)
        newPointStart.latitude = lineStart.latitude
        newPointStart.longitude = lineStart.longitude
        newPointStart.entryType = "Charging"
        newPointStart.mapID = "TestData"
        
        let newPointEnd = GPSDataPoint(context: context)
        newPointEnd.latitude = lineEnd.latitude
        newPointEnd.longitude = lineEnd.longitude
        newPointEnd.entryType = "Charging"
        newPointEnd.mapID = "TestData"
        
        do {
            try context.save()
            print("Test data initialized and saved.")
        } catch {
            print("Failed to save test data: \(error)")
        }
    }
}
