//
//  DovizAppUIApp.swift
//  DovizAppUI
//
//  Created by Bahadır Sengun on 22.09.2023.
//

import SwiftUI

@main
struct DovizAppUIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
