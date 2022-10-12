//
//  MsgrApp.swift
//  Msgr
//
//  Created by Aung Ko Min on 12/10/22.
//

import SwiftUI

@main
struct MsgrApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
