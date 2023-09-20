// Importing SwiftUI and CoreData frameworks
import SwiftUI
import CoreData

// ContentView struct serves as the main screen of the app
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
    
    // Main body of the ContentView
    var body: some View {
        // Creating a navigation view for better UI
        NavigationView {
            // Using a ZStack to layer the list and placeholder text
            ZStack {
                // List of GPS data points using card-based UI
                List {
                    ForEach(GPSDataPoints) { GPSDataPoint in
                        // Navigation link to GPSDataListVew (corrected the name)
                        NavigationLink(destination: GPSDataListView(gpsDataPoint: GPSDataPoint)) {
                            // Card layout for each GPS data point
                            VStack(alignment: .leading) {
                                Text(GPSDataPoint.timestamp!, formatter: itemFormatter)
                                    .font(.headline)
                                    .foregroundColor(Color.blue)
                                HStack {
                                    Text("Latitude: ")
                                        .font(.subheadline)
                                        .foregroundColor(Color.gray)
                                    Text(String(format: "%.8f", GPSDataPoint.latitude))
                                        .font(.subheadline)
                                        .foregroundColor(Color.green)
                                }
                                HStack {
                                    Text("Longitude: ")
                                        .font(.subheadline)
                                        .foregroundColor(Color.gray)
                                    Text(String(format: "%.8f", GPSDataPoint.longitude))
                                        .font(.subheadline)
                                        .foregroundColor(Color.red)
                                }
                            }
                            .padding()
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
                
                // Placeholder text when no item is selected
                // Text("Select an item")
                    .foregroundColor(Color.gray)
            }
        }
        .accentColor(Color.purple)  // Global accent color
    }
    
    // Function to add a new GPS data point
    private func addItem() {
        withAnimation {
            let newItem = GPSDataPoint(context: viewContext)
            newItem.timestamp = Date()
            newItem.latitude = 0.0
            newItem.longitude = 0.0
            
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

// Date formatter for formatting timestamps
private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

// Previewing the ContentView
struct GPSDataView_Previews: PreviewProvider {
    static var previews: some View {
        GPSDataView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
