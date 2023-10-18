
 // -----------------------------------------------------------
// File: PickerView.swift
// Created: 2023-10-14
//
// Overview:
// This file contains a SwiftUI Picker for selecting a Map ID.
// It populates the Picker based on unique mapIDs fetched from Core Data.
// Additionally, longitude and latitude are printed when a new Map ID is selected.
// -----------------------------------------------------------

import SwiftUI
import CoreData

// MARK: - PickerView Structure

struct PickerView: View {
    
    // MARK: - Properties
    
    // ViewModel for Core Data operations
    @ObservedObject var viewModel: ViewModel
    
    // Variable to hold the selected Map ID
    @State private var selectedMapID: String? = nil
    
    // Core Data context
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    // Initialize ViewModel with managed object context
    init(managedObjectContext: NSManagedObjectContext) {
        self.viewModel = ViewModel(context: managedObjectContext)
    }
    
    // MARK: - Body of the PickerView
    
    var body: some View {
        
        // MARK: - Picker Populated by Core Data
        
        VStack {
            // Picker to select a Map ID
            Picker("Select Map ID", selection: $selectedMapID) {
                
                // List of unique Map IDs
                ForEach(viewModel.uniqueMapIDs, id: \.self) { mapID in
                    
                    // Display Map ID
                    Text(mapID).tag(mapID as String?)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: selectedMapID) { newValue in
                
                // MARK: - Fetch and Log GPS Data on Picker Selection Change
                
                // Fetch and log GPS data
                if let selectedID = newValue {
                    viewModel.fetchAndLogGPSData(for: selectedID, in: managedObjectContext)
                }
                
                // Refetch unique Map IDs
                viewModel.fetchUniqueMapIDs(from: managedObjectContext)
            }
            .onAppear {
                // Initialize selected Map ID
                initializeSelection()
            }
        }
    }
    
    // MARK: - Helper Functions
    
    /// Initialize `selectedMapID` with the first unique Map ID, if available
    private func initializeSelection() {
        if let firstMapID = viewModel.uniqueMapIDs.first {
            selectedMapID = firstMapID
            print("**** selectedMapID initialized to: \(firstMapID)")
        }
    }
}

// MARK: - ViewModel Class

class ViewModel: ObservableObject {
    
    // MARK: - Properties
    
    // Unique Map IDs
    @Published var uniqueMapIDs: [String] = []
    
    // Initialize ViewModel and fetch unique Map IDs
    init(context: NSManagedObjectContext) {
        fetchUniqueMapIDs(from: context)
    }
    
    // MARK: - Core Data Functions
    
    /// Fetch unique Map IDs from Core Data
    func fetchUniqueMapIDs(from context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "GPSDataPoint")
        fetchRequest.propertiesToFetch = ["mapID"]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.resultType = .dictionaryResultType
        
        do {
            if let results = try context.fetch(fetchRequest) as? [[String: Any]] {
                self.uniqueMapIDs = results.compactMap { $0["mapID"] as? String }
            }
        } catch {
            print("**** Failed to fetch unique Map IDs: \(error)")
        }
    }
    
    /// Fetch and log GPS data for a specific Map ID
    func fetchAndLogGPSData(for mapID: String, in context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<GPSDataPoint> = GPSDataPoint.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "mapID == %@", mapID)
        
        do {
            let dataPoints = try context.fetch(fetchRequest)
            for dataPoint in dataPoints {
                print("**** Longitude: \(dataPoint.longitude), Latitude: \(dataPoint.latitude), Latitude: \(dataPoint.mapID)")
            }
        } catch {
            print("**** Failed to fetch GPS data: \(error)")
        }
    }
}

