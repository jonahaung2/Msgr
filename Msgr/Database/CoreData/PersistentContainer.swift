//
//  Persistence.swift
//  Msgr
//
//  Created by Aung Ko Min on 12/10/22.
//

import CoreData

class PersistentContainer: NSPersistentContainer {

    private static let lastCleanedKey = "lastCleaned"

    static let shared: PersistentContainer = {
//        ValueTransformer.setValueTransformer(ColorTransformer(), forName: NSValueTransformerName(rawValue: String(describing: ColorTransformer.self)))

        let container = PersistentContainer(name: "Msgr")
        container.loadPersistentStores { (desc, error) in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
        return container
    }()


    var lastCleaned: Date? {
        get {
            UserDefaults.standard.object(forKey: PersistentContainer.lastCleanedKey) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: PersistentContainer.lastCleanedKey)
        }
    }

    override func newBackgroundContext() -> NSManagedObjectContext {
        let backgroundContext = super.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyStoreTrumpMergePolicyType)
        return backgroundContext
    }

    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                print("saved context")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
