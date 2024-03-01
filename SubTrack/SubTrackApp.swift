//
//  SubTrackApp.swift
//  SubTrack
//
//  Created by Hashim Farooq on 2024-02-29.
//

import SwiftUI

@main
struct SubTrackApp: App {
   let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
               .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
