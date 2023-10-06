//
//  GPSDataView.swift
//  YourAppNameHere
//
//  Created by Igor on [Date & Time].
//
//  This file serves as the main interface for displaying GPS data points
//  fetched from CoreData. It provides functionalities like adding,
//  deleting, and viewing detailed information of GPS data points.
//

// MARK: - Imports

// Importing the SwiftUI framework for UI components
import SwiftUI
// Importing the CoreData framework for data persistence
import CoreData

// MARK: - Main View

// GPSDataView struct serves as the main screen of the app
struct GPSDataView: View {
    
    // MARK: - Properties
    
    // Accessing the CoreData storage
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetching GPS data points from CoreData and sorting them by timestamp
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \GPSDataPoint.timestamp, ascending: true)],
        animation: .default)
    private var GPSDataPoints: FetchedResults<GPSDataPoint>
    
    // State variable for showing the delete confirmation dialog
    @State private var showingDeleteAlert = false
    
    // Date formatter for formatting timestamps
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    // MARK: - Main UI
    
    // Main body of the ContentView
    var body: some View {
        // Creating a navigation view for better UI
        NavigationView {
            // Using a ZStack to layer the list and placeholder text
            ZStack {
                // List of GPS data points using card-based UI
                List {
                    // Loop through each GPSDataPoint object
                    ForEach(GPSDataPoints) { GPSDataPoint in
                        // Navigation link to GPSDataListView
                        NavigationLink(destination: GPSDataListView(gpsDataPoint: GPSDataPoint)) {
                            // Card layout for each GPS data point
                            VStack(alignment: .leading) {
                                // Displaying the timestamp in a short date and time format
                                HStack {
                                    Text("\(dateFormatter.string(from: GPSDataPoint.timestamp ?? Date()))")
                                        .font(.footnote)
                                        .foregroundColor(Color.black)
                                    Spacer() // Pushes the next element to the right
                                    Text("\(GPSDataPoint.mapID ?? "N/A")")
                                        .font(.footnote)
                                        .foregroundColor(Color.black)
                                }
                                // Displaying latitude and longitude
                                HStack {
                                    Text("Lat: ")
                                        .font(.footnote)
                                        .foregroundColor(Color.black)
                                    Text(String(format: "%.7f", GPSDataPoint.latitude))
                                        .font(.footnote)
                                        .foregroundColor(Color.green)
                                    Spacer() // Pushes the next element to the right
                                    Text("\(GPSDataPoint.entryType ?? "Missing")")
                                        .font(.footnote)
                                        .foregroundColor(Color.black)
                                }
                                HStack {
                                    Text("Lon")
                                        .font(.footnote)
                                        .foregroundColor(Color.black)
                                    Text(String(format: "%.7f", GPSDataPoint.longitude))
                                        .font(.footnote)
                                        .foregroundColor(Color.red)
                                    Spacer() // Pushes the next element to the right
                                    Text("\(GPSDataPoint.mowingPattern ?? "Missing")")
                                        .font(.footnote)
                                        .foregroundColor(Color.black)
                                }
                            }
                            .padding(5)
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(8)
                        }
                    }
                    .onDelete(perform: deleteItems) // Enables the swipe-to-delete functionality
                }
                .listStyle(InsetGroupedListStyle()) // Sets the list style
                
                // MARK: - Toolbar
                
                // Toolbar with Edit, Add, and Delete All buttons
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Delete All") {
                            showingDeleteAlert = true // Shows the delete confirmation alert
                        }
                        .alert(isPresented: $showingDeleteAlert) {
                            // Define the alert dialog
                            Alert(title: Text("Are you sure?"),
                                  message: Text("This will delete all records."),
                                  primaryButton: .destructive(Text("Delete")) {
                                deleteAllRecords() // Deletes all records when this button is pressed
                            },
                                  secondaryButton: .cancel()) // Cancel button
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton() // Built-in edit button to toggle list editing mode
                    }
                    ToolbarItem {
                        Button(action: addItem) { // Button to add a new GPS data point
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    /// Function to add a new GPS data point
    private func addItem() {
        withAnimation {
            let newItem = GPSDataPoint(context: viewContext) // Create a new GPSDataPoint object
            newItem.timestamp = Date() // Set the current date and time as the timestamp
            newItem.latitude = 0.0 // Initialize latitude to 0.0
            newItem.longitude = 0.0 // Initialize longitude to 0.0
            newItem.mapID = "Default" // Set a default map ID
            newItem.entryType = "Default" // Set a default entry type
            newItem.mowingPattern = "Default" // Set a default mowing pattern
            
            do {
                try viewContext.save() // Save the new item to CoreData
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    /// Function to delete selected GPS data points
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { GPSDataPoints[$0] }.forEach(viewContext.delete) // Delete each selected item
            
            do {
                try viewContext.save() // Save the changes to CoreData
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    /// Function to delete all GPS data points
    private func deleteAllRecords() {
        for dataPoint in GPSDataPoints { // Loop through all data points
            viewContext.delete(dataPoint) // Delete each data point
        }
        
        do {
            try viewContext.save() // Save the changes to CoreData
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

// MARK: - Preview

// Previewing the GPSDataView
struct GPSDataView_Previews: PreviewProvider {
    static var previews: some View {
        GPSDataView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
