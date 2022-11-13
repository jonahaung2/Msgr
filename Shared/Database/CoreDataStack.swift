//
//  Persistence.swift
//  Msgr
//
//  Created by Aung Ko Min on 12/10/22.
//

import CoreData
import UIKit
//
//final class CoreDataStack {
//
//    static let shared = CoreDataStack(moduleName: "Msgr")
//    private let moduleName: String
//
//    private(set) lazy var viewContext: NSManagedObjectContext = {
//        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//        context.parent = mainContext
//        context.automaticallyMergesChangesFromParent = true
//        context.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyStoreTrumpMergePolicyType)
//        return context
//    }()
//
//    private lazy var mainContext: NSManagedObjectContext = {
//        let context = persistantContainer.viewContext
//        context.automaticallyMergesChangesFromParent = true
//        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
//        return context
//    }()
//
//    init(moduleName: String) {
//        self.moduleName = moduleName
//        loadPersistantStore {
//            //TODO:
//        }
//    }
//
//    private(set) lazy var persistantContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: self.moduleName)
//        let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.aungkomin.Msgr.v3")!
//        let storeName = "\(self.moduleName).sqlite"
//        let storeUrl =  directory.appendingPathComponent(storeName)
//        let description =  NSPersistentStoreDescription(url: storeUrl)
//        description.shouldMigrateStoreAutomatically = true
//        description.shouldInferMappingModelAutomatically = true
//        container.persistentStoreDescriptions = [description]
//        return container
//    }()
//
//    private func loadPersistantStore(completionHandler: @escaping () -> Void) -> Void {
//        persistantContainer.loadPersistentStores { (_, error) in
//            if let _ = error {
//                fatalError("Error in loading persistant store")
//            } else {
//                completionHandler()
//            }
//        }
//    }
//
//    func performSyncOperation(block: () -> Void) -> Void {
//        viewContext.performAndWait {
//            block()
//        }
//    }
//    func performAsyncOperation(block: @escaping () -> Void) -> Void {
//        viewContext.perform {
//            block()
//        }
//    }
//
//    func save() {
//        if self.viewContext.hasChanges {
//            do {
//                try self.viewContext.save()
//            } catch {
//                print("saving error 1")
//            }
//            do {
//                try self.mainContext.save()
//            } catch {
//                print("saving error 2")
//            }
//        }
//    }
//}

extension NSManagedObjectContext {
    static func sync(context: NSManagedObjectContext) {
        do {
            try context.save()
            if let parent = context.parent {
                self.sync(context: parent)
            }
        } catch {
            print(error)
        }
    }
}
final class CoreDataStack {

    static let shared = CoreDataStack(modelName: "Msgr")

    private let modelName: String

    init(modelName: String) {
        self.modelName = modelName
    }
    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistantStoreCoordinator
        return context
    }()

    private(set) lazy var viewContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = self.privateManagedObjectContext
        return context
    }()

    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let dataModelUrl = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else { fatalError("unable to find data model url") }
        guard let dataModel = NSManagedObjectModel(contentsOf: dataModelUrl) else { fatalError("unable to find data model") }
        return dataModel
    }()

    private lazy var persistantStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let fileManager = FileManager.default
        let storeName = "\(self.modelName).sqlite"
        let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.aungkomin.Msgr.v3")!
        let storeUrl =  directory.appendingPathComponent(storeName)
        do {
            //MARK: for LightWeight Migration
            let options = [
                NSMigratePersistentStoresAutomaticallyOption : true,
                NSInferMappingModelAutomaticallyOption : true,
            ]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: options)
        } catch {
            fatalError("unable to add store")
        }
        return coordinator
    }()

    func save() {
        viewContext.perform {
            do {
                if self.viewContext.hasChanges {
                    try self.viewContext.save()
                }
            } catch {
                print("saving error : child : - \(error.localizedDescription)")
            }
            do {
                if self.privateManagedObjectContext.hasChanges {
                    try self.privateManagedObjectContext.save()
                }
            } catch {
                print("saving error : parent : - \(error.localizedDescription)")
            }
            print("saved")
        }
    }
}



//class PersistentContainer: NSPersistentContainer {
//
//    private static let lastCleanedKey = "lastCleaned"
//
//    static let shared: PersistentContainer = {
//        let container = PersistentContainer(name: "Msgr")
//        container.loadPersistentStores { (desc, error) in
//            if let error = error {
//                fatalError("Unresolved error \(error)")
//            }
//        }
//        container.viewContext.automaticallyMergesChangesFromParent = true
//        container.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
//        return container
//    }()
//
//    override func newBackgroundContext() -> NSManagedObjectContext {
//        let backgroundContext = super.newBackgroundContext()
//        backgroundContext.automaticallyMergesChangesFromParent = true
//        backgroundContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyStoreTrumpMergePolicyType)
//        return backgroundContext
//    }
//
//    func save() {
//        if viewContext.hasChanges {
//            do {
//                try viewContext.save()
//                print("saved context")
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//    }
//}
