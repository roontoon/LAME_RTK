// Importing SwiftUI and CoreData frameworks
import SwiftUI
import CoreData

// GPSDataView struct serves as the main screen of the app
struct GPSDataView: View {
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
    
    // Main body of the ContentView
    var body: some View {
        // Creating a navigation view for better UI
        NavigationView {
            // Using a ZStack to layer the list and placeholder text
            ZStack {
                // List of GPS data points using card-based UI
                List {
                    ForEach(GPSDataPoints) { GPSDataPoint in
                        // Navigation link to GPSDataListView
                        NavigationLink(destination: GPSDataListView(gpsDataPoint: GPSDataPoint)) {
                            // Card layout for each GPS data point
                            HStack {
                                // Left-aligned VStack
                                VStack(alignment: .leading) {
                                    // Displaying the timestamp in a short date and time format
                                    Text("\(dateFormatter.string(from: GPSDataPoint.timestamp ?? Date()))")
                                        .font(.footnote)
                                        .foregroundColor(Color.green)
                                    
                                    // Displaying latitude
                                    Text("Latitude: \(String(format: "%.8f", GPSDataPoint.latitude))")
                                        .font(.footnote)
                                        .foregroundColor(Color.green)
                                    
                                    // Displaying longitude
                                    Text("Longitude: \(String(format: "%.8f", GPSDataPoint.longitude))")
                                        .font(.footnote)
                                        .foregroundColor(Color.red)
                                }
                                
                                // Spacer for pushing the next VStack to the right
                                Spacer()
                                
                                // Right-aligned VStack
                                VStack(alignment: .trailing) {
                                    // Displaying MapID (Assuming MapID is a String)
                                    Text("\(GPSDataPoint.mapID ?? "Missing")")
                                        .font(.footnote)
                                        .foregroundColor(Color.blue)
                                    
                                    // Displaying EntryTyp (Assuming EntryType is a String)
                                    Text("\(GPSDataPoint.entryType ?? "Missing")")
                                        .font(.footnote)
                                        .foregroundColor(Color.blue)
                                    
                                    // Displaying MowingPattern (Assuming MowingPattern is a String)
                                    Text("\(GPSDataPoint.mowingPattern ?? "Missing")")
                                        .font(.footnote)
                                        .foregroundColor(Color.blue)
                                }
                            }
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(8)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(InsetGroupedListStyle())
                
                // Toolbar with Edit, Add, and Delete All buttons
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Delete All") {
                            showingDeleteAlert = true
                        }
                        .alert(isPresented: $showingDeleteAlert) {
                            Alert(title: Text("Are you sure?"),
                                  message: Text("This will delete all records."),
                                  primaryButton: .destructive(Text("Delete")) {
                                    deleteAllRecords()
                                },
                                  secondaryButton: .cancel())
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem {
                        Button(action: addItem) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
            }
        }
    }
    
    // Function to add a new GPS data point
    private func addItem() {
        withAnimation {
            let newItem = GPSDataPoint(context: viewContext)
            newItem.timestamp = Date()
            newItem.latitude = 0.0
            newItem.longitude = 0.0
            // Assuming you have these attributes in your CoreData model
            newItem.mapID = "Default MapID"
            newItem.entryType = "Default EntryType"
            newItem.mowingPattern = "Default MowingPattern"
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // Function to delete selected GPS data points
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { GPSDataPoints[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // Function to delete all GPS data points
    private func deleteAllRecords() {
        for dataPoint in GPSDataPoints {
            viewContext.delete(dataPoint)
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

// Previewing the ContentView
struct GPSDataView_Previews: PreviewProvider {
    static var previews: some View {
        GPSDataView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
