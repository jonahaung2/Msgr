/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A collection of classes, extensions, and functions for fetching, adding, and deleting feed entries from the database.
*/

import Foundation
import CoreData

struct Operations {
    
    static func getOperationsToFetchLatestEntries(using context: NSManagedObjectContext, server: MockServer) -> [Operation] {

        let fetchMostRecentEntry = FetchMostRecentEntryOperation(context: context)
        let downloadFromServer = DownloadEntriesFromServerOperation(context: context, server: server)

        let passTimestampToServer = BlockOperation { [unowned fetchMostRecentEntry, unowned downloadFromServer] in
            guard let date = fetchMostRecentEntry.result?.date else {
                downloadFromServer.cancel()
                return
            }
            downloadFromServer.sinceDate = date
        }

        passTimestampToServer.addDependency(fetchMostRecentEntry)
        downloadFromServer.addDependency(passTimestampToServer)


        let addToStore = AddEntriesToStoreOperation()

        let passServerResultsToStore = BlockOperation { [unowned downloadFromServer, unowned addToStore] in
            guard case let .success(entries)? = downloadFromServer.result else {
                addToStore.cancel()
                return
            }
            addToStore.entries = entries
        }
        passServerResultsToStore.addDependency(downloadFromServer)
        addToStore.addDependency(passServerResultsToStore)
        
        return [fetchMostRecentEntry, passTimestampToServer, downloadFromServer, passServerResultsToStore, addToStore]
    }
}

// Fetches the most recent entry from the Core Data store.
class FetchMostRecentEntryOperation: Operation {
    
    private let context: NSManagedObjectContext
    var result: Msg?
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    override func main() {
        let request: NSFetchRequest<Msg> = Msg.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Msg.date), ascending: true)]
        request.fetchLimit = 1
        context.performAndWait {
            do {
                let fetchResult = try context.fetch(request)
                guard !fetchResult.isEmpty else { return }
                print(fetchResult)
                result = fetchResult[0]
            } catch {
                print("Error fetching from context: \(error)")
            }
        }
    }
}

// Downloads entries created after the specified date.
class DownloadEntriesFromServerOperation: Operation {

    enum OperationError: Error {
        case cancelled
    }

    private let context: NSManagedObjectContext
    private let server: MockServer
    var sinceDate: Date?
    
    var result: Result<[Msg.Payload], Error>?
    
    private var downloading = false
    private var currentDownloadTask: DownloadTask?
    
    init(context: NSManagedObjectContext, server: MockServer) {
        self.context = context
        self.server = server
    }
    
    convenience init(context: NSManagedObjectContext, server: MockServer, sinceDate: Date?) {
        self.init(context: context, server: server)
        self.sinceDate = sinceDate
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        return downloading
    }
    
    override var isFinished: Bool {
        return result != nil
    }
    
    override func cancel() {
        super.cancel()
        if let currentDownloadTask = currentDownloadTask {
            currentDownloadTask.cancel()
        }
    }
    
    func finish(result: Result<[Msg.Payload], Error>) {
        guard downloading else { return }
        
        willChangeValue(forKey: #keyPath(isExecuting))
        willChangeValue(forKey: #keyPath(isFinished))
        
        downloading = false
        self.result = result
        currentDownloadTask = nil
        
        didChangeValue(forKey: #keyPath(isFinished))
        didChangeValue(forKey: #keyPath(isExecuting))
    }

    override func start() {
        willChangeValue(forKey: #keyPath(isExecuting))
        downloading = true
        didChangeValue(forKey: #keyPath(isExecuting))
        
        guard !isCancelled, let sinceDate = sinceDate else {
            finish(result: .failure(OperationError.cancelled))
            return
        }
        
        currentDownloadTask = server.fetchEntries(since: sinceDate, completion: finish)
    }
}


// Add entries returned from the server to the Core Data store.
class AddEntriesToStoreOperation: Operation {

    var entries: [Msg.Payload]?
    var delay: TimeInterval = 1

    override init() {}
    
    convenience init(entries: [Msg.Payload], delay: TimeInterval? = nil) {
        self.init()
        self.entries = entries
        if let delay = delay {
            self.delay = delay
        }
    }
    
    override func main() {
        guard let entries = entries else { return }

        for entry in entries {
            CoreDataStore.shared.insert(payload: entry, informSavedNotification: false)

            print("Adding entry with timestamp: \(entry.date)")

            // Simulate a slow process by sleeping
            if delay > 0 {
                Thread.sleep(forTimeInterval: delay)
            }

            if isCancelled {
                break
            }
        }
    }
}

