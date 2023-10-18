// SharedViewModel.swift
/*
import Combine
import SwiftUI
import CoreData

class SharedViewModel: ObservableObject {
    @Published var uniqueMapIDs: [String] = []
    
    let managedObjectContext = PersistenceController.shared.container.viewContext
    
    init() {
        print("SharedViewModel fetchUniqueMapIDs")
        fetchUniqueMapIDs()
    }
    
    // Function to fetch unique map IDs from Core Data
    func fetchUniqueMapIDs() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "GPSDataPoint")
        fetchRequest.propertiesToFetch = ["mapID"]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.resultType = .dictionaryResultType
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest) as! [[String: Any]]
            let uniqueMapIDs = results.compactMap { $0["mapID"] as? String }
            self.uniqueMapIDs = uniqueMapIDs
            print("***** Fetched unique mapIDs: \(uniqueMapIDs)")
        } catch {
            print("Failed to fetch unique mapIDs: \(error)")
        }
    }
}
*/
