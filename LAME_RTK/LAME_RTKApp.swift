//
//  LAME_RTKApp.swift
//  LAME_RTK
//
//  Created by Roontoon on 9/11/23.
//
import SwiftUI

@main

struct LAME_RTKApp: App {
    let persistenceController = PersistenceController.shared
    // This is like a sensor that tells us what's happening with our app (is it active, in the background, etc.)
    @Environment(\.scenePhase) var scenePhase
    var body: some Scene {
        // This is the main window of our app.
        WindowGroup {
            // We start with the ContentView and give it access to where we save our data.
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        // This is the new way to check if something changed in our app's state.
        .onChange(of: scenePhase) {
            // We don't need to know what the old or new phase is, we just save our data.
            persistenceController.save()
        }
    }
}
