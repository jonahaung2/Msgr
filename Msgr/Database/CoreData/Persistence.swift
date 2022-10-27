//
//  Persistence.swift
//  Msgr
//
//  Created by Aung Ko Min on 12/10/22.
//

import CoreData

class Persistence {

    static let shared = Persistence()
    private let container: NSPersistentCloudKitContainer

    var context: NSManagedObjectContext {
        container.viewContext
    }

    private init() {
        container = NSPersistentCloudKitContainer(name: "Msgr")
        // container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error {
                fatalError(error.localizedDescription)
            }
        })
    }

    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

