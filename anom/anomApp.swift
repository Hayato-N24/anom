//
//  anomApp.swift
//  anom
//
//  Created by 中村隼人 on 2021/05/26.
//

import SwiftUI

@main
struct anomApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
