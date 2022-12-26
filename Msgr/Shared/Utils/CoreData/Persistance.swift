//
//  Persistence.swift
//  Msgr
//
//  Created by Aung Ko Min on 12/10/22.
//

import CoreData

final class Persistance {

    static let shared = Persistance()

    private lazy var persistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Msgr")
        let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.aungkomin.Msgr.v3")!
        let storeName = "Msgr.sqlite"

        let storeUrl =  directory.appendingPathComponent(storeName)
        let description =  NSPersistentStoreDescription(url: storeUrl)
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]
        return container
    }()

    var viewContext: NSManagedObjectContext { persistantContainer.viewContext }
    func newTaskContext() -> NSManagedObjectContext {
        let taskContext = persistantContainer.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return taskContext
    }

    init() {
        persistantContainer.loadPersistentStores {[weak self]  _, error in
            guard let self = self else { return }

            if let error {
                fatalError(error.localizedDescription)
            } else {
                self.persistantContainer.viewContext.automaticallyMergesChangesFromParent = false
                self.persistantContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                self.persistantContainer.viewContext.shouldDeleteInaccessibleFaults = true
                self.persistantContainer.viewContext.name = "ViewContext"
                self.persistantContainer.viewContext.transactionAuthor = GroupContainer.appGroupId
            }
        }
    }


}

enum CoreDataError: Error {
    case wrongDataFormat(error: Error)
    case missingData
    case creationError
    case batchInsertError
    case batchDeleteError
    case persistentHistoryChangeError
    case unexpectedError(error: Error)
}

extension CoreDataError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .wrongDataFormat(let error):
            return NSLocalizedString("Could not digest the fetched data. \(error.localizedDescription)", comment: "")
        case .missingData:
            return NSLocalizedString("Found and will discard a quake missing a valid code, magnitude, place, or time.", comment: "")
        case .creationError:
            return NSLocalizedString("Failed to create a new Quake object.", comment: "")
        case .batchInsertError:
            return NSLocalizedString("Failed to execute a batch insert request.", comment: "")
        case .batchDeleteError:
            return NSLocalizedString("Failed to execute a batch delete request.", comment: "")
        case .persistentHistoryChangeError:
            return NSLocalizedString("Failed to execute a persistent history change request.", comment: "")
        case .unexpectedError(let error):
            return NSLocalizedString("Received unexpected error. \(error.localizedDescription)", comment: "")
        }
    }
}

extension CoreDataError: Identifiable {
    var id: String? {
        errorDescription
    }
}

//final class CoreDataStack {
//
//    static let shared = CoreDataStack(modelName: "Msgr")
//
//    private let modelName: String
//
//    init(modelName: String) {
//        self.modelName = modelName
//    }
//    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
//        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//        context.persistentStoreCoordinator = self.persistantStoreCoordinator
//        return context
//    }()
//
//    private(set) lazy var viewContext: NSManagedObjectContext = {
//        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//        context.parent = self.privateManagedObjectContext
//        return context
//    }()
//
//    private lazy var managedObjectModel: NSManagedObjectModel = {
//        guard let dataModelUrl = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else { fatalError("unable to find data model url") }
//        guard let dataModel = NSManagedObjectModel(contentsOf: dataModelUrl) else { fatalError("unable to find data model") }
//        return dataModel
//    }()
//
//    private lazy var persistantStoreCoordinator: NSPersistentStoreCoordinator = {
//        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
//        let fileManager = FileManager.default
//        let storeName = "\(self.modelName).sqlite"
//        let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.aungkomin.Msgr.v3")!
//        let storeUrl =  directory.appendingPathComponent(storeName)
//        do {
//            //MARK: for LightWeight Migration
//            let options = [
//                NSMigratePersistentStoresAutomaticallyOption : true,
//                NSInferMappingModelAutomaticallyOption : true,
//            ]
//            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: options)
//        } catch {
//            fatalError("unable to add store")
//        }
//        return coordinator
//    }()
//
//    func save() {
//        viewContext.perform {
//            do {
//                if self.viewContext.hasChanges {
//                    try self.viewContext.save()
//                }
//            } catch {
//                print("saving error : child : - \(error.localizedDescription)")
//            }
//            do {
//                if self.privateManagedObjectContext.hasChanges {
//                    try self.privateManagedObjectContext.save()
//                }
//            } catch {
//                print("saving error : parent : - \(error.localizedDescription)")
//            }
//            print("saved")
//        }
//    }
//}



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
