//
//  CoreDataChanges.swift
//  Msgr
//
//  Created by Aung Ko Min on 12/12/22.
//

import Foundation
import CoreData

final class PersistanceChanges {

    static let shared = PersistanceChanges()

    private let queue: OperationQueue = {
        $0.maxConcurrentOperationCount = 1
        return $0
    }(OperationQueue())

    private let context: NSManagedObjectContext

    private init() {
        context = Persistance.shared.newTaskContext()
    }

    private var observer: NSObjectProtocol?
    func startObserving() {
        removeObserver()
        observer = NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: nil, queue: queue) { [weak self] _ in
            self?.processPersistentHistory()
        }
    }

    func removeObserver() {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    deinit {
        removeObserver()
    }

    @objc private func processPersistentHistory() {
        context.performAndWait {
            do {
                let merger = PersistentHistoryMerger(backgroundContext: context, viewContext: Persistance.shared.viewContext)
                try merger.merge()

                let cleaner = PersistentHistoryCleaner(context: context)
                try cleaner.clean()
            } catch {
                Log(error)
            }
        }
    }
}

struct PersistentHistoryMerger {
    let backgroundContext: NSManagedObjectContext
    let viewContext: NSManagedObjectContext

    func merge() throws {
        let fromDate = GroupContainer.lastHistoryTransactionTimestamp ?? .distantPast
        let fetcher = PersistentHistoryFetcher(context: backgroundContext, fromDate: fromDate)
        let history = try fetcher.fetch()
        guard !history.isEmpty else { return }
        history.merge(into: backgroundContext)
        viewContext.perform {
            history.merge(into: self.viewContext)
        }
        guard let lastTimestamp = history.last?.timestamp else { return }
        GroupContainer.lastHistoryTransactionTimestamp = lastTimestamp
    }
}

extension Collection where Element == NSPersistentHistoryTransaction {
    func merge(into context: NSManagedObjectContext) {
        forEach { transaction in
            guard let userInfo = transaction.objectIDNotification().userInfo else { return }
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: userInfo, into: [context])
        }
    }
}

struct PersistentHistoryFetcher {

    enum Error: Swift.Error {
        case historyTransactionConvertionFailed
    }

    let context: NSManagedObjectContext
    let fromDate: Date

    func fetch() throws -> [NSPersistentHistoryTransaction] {
        let fetchRequest = createFetchRequest()
        guard let historyResult = try context.execute(fetchRequest) as? NSPersistentHistoryResult, let history = historyResult.result as? [NSPersistentHistoryTransaction] else {
            throw Error.historyTransactionConvertionFailed
        }
        return history
    }

    func createFetchRequest() -> NSPersistentHistoryChangeRequest {
        let request = NSPersistentHistoryChangeRequest.fetchHistory(after: fromDate)
        if let fetchRequest = NSPersistentHistoryTransaction.fetchRequest {
            var predicates: [NSPredicate] = []
            if let transactionAuthor = context.transactionAuthor {
                predicates.append(NSPredicate(format: "%K != %@", #keyPath(NSPersistentHistoryTransaction.author), transactionAuthor))
            }
            if let contextName = context.name {
                predicates.append(NSPredicate(format: "%K != %@", #keyPath(NSPersistentHistoryTransaction.contextName), contextName))
            }
            fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
            request.fetchRequest = fetchRequest
        }
        return request
    }
}

struct PersistentHistoryCleaner {
    let context: NSManagedObjectContext
    func clean() throws {
        guard let timestamp = GroupContainer.lastHistoryTransactionTimestamp else {
            return
        }

        let deleteHistoryRequest = NSPersistentHistoryChangeRequest.deleteHistory(before: timestamp)
        try context.execute(deleteHistoryRequest)
        GroupContainer.lastHistoryTransactionTimestamp = nil
    }
}
