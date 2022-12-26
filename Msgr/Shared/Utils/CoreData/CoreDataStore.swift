//
//  CoreDataStore.swift
//  Msgr
//
//  Created by Aung Ko Min on 6/11/22.
//

import Foundation
import CoreData

final class CoreDataStore {
    
    static let shared = CoreDataStore()

    private let queue: OperationQueue = {
        $0.name = "CoreDataStore"
        $0.maxConcurrentOperationCount = 1
        return $0
    }(OperationQueue())

    private let context: NSManagedObjectContext

    private init() {
        context = Persistance.shared.newTaskContext()
    }

    func save(msgPL payload: Msg.Payload) {
        queue.addOperation { [weak self] in
            guard let self = self else { return }
            let context = self.context
            context.perform {
                Msg.save(payload: payload, context)
                self.saveContext()
            }
        }
    }

    func save(contact payload: Contact.Payload) {
        queue.addOperation { [weak self] in
            guard let self = self else { return }
            let context = self.context
            context.perform {
                Contact.save(payload, context: context)
                self.saveContext()
            }
        }
    }

    func save(groupInfo payload: GroupInfo.Payload) {
        queue.addOperation { [weak self] in
            guard let self = self else { return }
            let context = self.context
            context.perform {
                GroupInfo.save(payload, context: context)
                self.saveContext()
            }
        }
    }

    func update(contactIDs: [String]) {
        let context = self.context
        let ops = contactIDs.map { id in
            let op = AsyncOperation { op, handler in
                context.perform {
                    Contact.fetchRemotePayload(id: id) { payload in
                        if let payload {
                            Contact.save(payload, context: context)
                        }
                        handler(.continue)
                    }
                }
            }
            return op
        }
        ops.last?.completionBlock = { [weak self] in
            self?.saveContext()
        }
        queue.addOperations(ops, waitUntilFinished: false)
    }

    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
                Log("context saved")
            } catch {
                Log(error)
            }
        }
    }
}

// Msg
extension CoreDataStore {
    
    func update(msg id: String, deliveryStatus: Msg.DeliveryStatus) {
        let operation = AsyncOperation { [weak self] op, output in
            guard let self = self else {
                op.cancel()
                return
            }
            let context = self.context
            context.perform {
                if let msg = Msg.object(for: id, context) {
                    msg.deliveryStatus_ = deliveryStatus.rawValue
                }
                output(.continue)
            }
        }
        operation.completionBlock = saveContext
        queue.addOperation(operation)
    }
}

extension CoreDataStore {

    /// Asynchronously deletes records in the Core Data store with the specified `Quake` managed objects.
    func deleteObjects(_ objectIDs: [NSManagedObjectID]) {
        queue.addOperation { [weak self] in
            guard let self = self else { return }
            let context = self.context
            context.perform {
                let request = NSBatchDeleteRequest(objectIDs: objectIDs)
                guard let results = try? context.execute(request),
                      let batchDeleteResult = results as? NSBatchDeleteResult,
                      let success = batchDeleteResult.result as? Bool, success
                else {
                    return
                }
                self.saveContext()
            }
        }
    }

    func deleteAllRecords(entity : String) {
        queue.addOperation { [weak self] in
            guard let self = self else { return }
            let context = self.context
            context.perform {
                let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
                guard let fetchResult = try? context.execute(deleteRequest),
                      let batchDeleteResult = fetchResult as? NSBatchDeleteResult,
                      let success = batchDeleteResult.result as? Bool, success
                else {
                    return
                }
                self.saveContext()
            }
        }
    }
}
