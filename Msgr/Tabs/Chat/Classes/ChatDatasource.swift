//
//  ChatDatasource.swift
//  Msgr
//
//  Created by Aung Ko Min on 27/10/22.
//

import SwiftUI
import CoreData

final class ChatDatasource: NSObject, ObservableObject {

    typealias MsgPair = (prev: Msg?, msg: Msg, next: Msg?)
    private let pageSize = 30
    private var currentPage = 1

    private let frc: NSFetchedResultsController<Msg>
    private let conID: String
    var blocks = [MsgPair]()
    var allMsgsCount = 0
    private var isFetching = false

    init(_ conId: String) {
        conID = conId
        frc = {
            let fetchRequest = {
                $0.predicate = NSPredicate(format: "conId == %@", conId)
                $0.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                $0.fetchLimit = 30
                return $0
            }(Msg.fetchRequest())
            return .init(fetchRequest: fetchRequest, managedObjectContext: Persistance.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        }()
        super.init()
        allMsgsCount = Con.allMsgsCount(for: conId)
        fetch()
        frc.delegate = self
    }

    private func fetch(_ block: (() -> Void)? = nil) {
        do {
            try frc.managedObjectContext.performAndWait {
                frc.fetchRequest.fetchLimit = pageSize*currentPage
                try frc.performFetch()
                generateItems()
                block?()
            }
        } catch {
            Log(error)
            block?()
        }
    }
    
    func loadMoreIfNeeded(_ block: (() -> Void)? = nil) {
        guard !isFetching && allMsgsCount > pageSize && currentPage*pageSize <= allMsgsCount else {
            return
        }
        isFetching = true
        currentPage += 1
        fetch(block)

    }

    func reset(_ block: (() -> Void)? = nil ) {
        guard currentPage > 2 else {
            block?()
            return
        }
        currentPage = 2
        fetch(block)
    }

    deinit {
        Log("Chat Datasource")
    }

    private func generateItems(_ block: (() -> Void)? = nil) {
        let msgs = frc.fetchedObjects ?? []
        blocks = msgs.withPreviousAndNext
        isFetching = false
        block?()
    }
}

extension ChatDatasource: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        generateItems { [weak self] in
            guard let self else { return }
            self.allMsgsCount = Con.allMsgsCount(for: self.conID)
            self.objectWillChange.send()
        }
    }
}

extension Sequence {
    var withPreviousAndNext: [(Element?, Element, Element?)] {
        let optionalSelf = self.map(Optional.some)
        let next = optionalSelf.dropFirst() + [nil]
        let prev = [nil] + optionalSelf.dropLast()
        return zip(self, zip(prev, next)).map {
            ($1.0, $0, $1.1)
        }
    }
}
