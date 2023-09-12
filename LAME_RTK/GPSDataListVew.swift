//
//  GPSDataListVew.swift
//  LAME_RTK
//
//  Created by Roontoon on 9/12/23.
//
import SwiftUI
import CoreData

struct GPSDataListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var dataPoint: GPSDataPoint

    @State private var latitude: Double = 0
    @State private var longitude: Double = 0

    var body: some View {
        Form {
            Section(header: Text("Edit GPS Data")) {
                TextField("Latitude", value: $latitude, formatter: NumberFormatter())
                TextField("Longitude", value: $longitude, formatter: NumberFormatter())
            }
        }
        .navigationBarTitle("Edit GPS Data")
        .onAppear {
            self.latitude = dataModel.latitude
            self.longitude = dataModel.longitude
        }
        .navigationBarItems(trailing: Button("Save") {
            dataModel.latitude = latitude
            dataModel.longitude = longitude
            do {
                try viewContext.save()
            } catch {
                print("Failed to save changes: \(error)")
            }
        })
    }
}
