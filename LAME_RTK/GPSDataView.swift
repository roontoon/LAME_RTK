// Importing necessary modules
import SwiftUI
import CoreData

// GPSDataView struct defines the UI and behavior for displaying GPS data points.
struct GPSDataView: View {
    
    // Using sort descriptors to sort the fetched results based on the timestamp.
    // Changed from GPSDataModel to GPSDataPoint
    @FetchRequest(
        entity: GPSDataPoint.entity(),  // Corrected line
        sortDescriptors: [NSSortDescriptor(keyPath: \GPSDataPoint.timestamp, ascending: true)]  // Corrected line
    ) private var gpsDataPoints: FetchedResults<GPSDataPoint>  // Corrected line

    
    // The body property defines the UI elements that make up the GPSDataView.
    var body: some View {
        // Using a List to display each GPS data point.
        List {
            // Using ForEach to iterate through each GPS data point.
            // Changed from gpsDataModels to gpsDataPoints
            ForEach(gpsDataPoints, id: \.self) { dataPoint in
                // Displaying the data point (this part depends on how your GPSDataPoint is structured)
                Text("Data Point Info Here")
            }
        }
    }
}
