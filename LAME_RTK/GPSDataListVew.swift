import SwiftUI
import CoreData

struct GPSDataListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \GPSDataPoint.timestamp, ascending: true)],
        animation: .default)
    private var gpsDataPoints: FetchedResults<GPSDataPoint>

    // DateFormatter
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        NavigationView {
            List {
                ForEach(gpsDataPoints, id: \.self) { dataPoint in
                    NavigationLink(destination: EditView(dataPoint: dataPoint)) {
                        VStack {
                            Text("Timestamp: \(itemFormatter.string(from: dataPoint.timestamp ?? Date()))")
                            Text("Latitude: \(dataPoint.latitude)")
                            Text("Longitude: \(dataPoint.longitude)")
                            Text("Entry Type: \(dataPoint.entryType ?? "")")
                            Text("Map ID: \(dataPoint.mapID ?? "")")
                            Text("Mowing Pattern: \(dataPoint.mowingPattern ?? "")")
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitle("GPS Data Points", displayMode: .inline)
            .navigationBarItems(trailing: Button("Delete All") {
                deleteAllRecords()
            })
        }
    }

    private func deleteAllRecords() {
        for dataPoint in gpsDataPoints {
            viewContext.delete(dataPoint)
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            // Suggested: Replace fatalError with better error handling
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
