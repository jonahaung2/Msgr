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
    typealias Completion = (() -> Void)?
    private let mainContext: NSManagedObjectContext
    private let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)

    private let queue: OperationQueue = {
        $0.name = "CoreDataStore"
        $0.maxConcurrentOperationCount = 1
        $0.qualityOfService = .userInitiated
        return $0
    }(OperationQueue())

    private init() {
        mainContext = CoreDataStack.shared.viewContext
        backgroundContext.parent = self.mainContext
    }
}

// Msg
extension CoreDataStore {

    func insert(payload: Msg.Payload, informSavedNotification: Bool) {
        let operation = MsgCreateOperation(payload: payload, context: backgroundContext, informSavedNotification: informSavedNotification)
        queue.addOperation(operation)
    }

    func insert(payload: Contact.Payload) {
        let operation = ContactCreateOperation(payload: payload, context: backgroundContext)
        queue.addOperation(operation)
    }
}

extension Msg {
    func sync(payload: Msg.Payload) {
        if self.id != payload.id {
            self.id = payload.id
        }
        if self.text != payload.text {
            self.text = payload.text
        }
        if self.conId != payload.conId {
            self.conId = payload.id
        }
        if self.senderId != payload.senderId {
            self.senderId = payload.senderId
        }
        if self.date != payload.date {
            self.date = payload.date
        }
        if self.text != payload.text {
            self.text = payload.text
        }
        if self.msgType_ != payload.msgType {
            self.msgType_ = payload.msgType
        }
    }
}
extension Contact {
    func sync(payload: Contact.Payload) {
        if self.id != payload.id {
            self.id = payload.id
        }
        if self.name != payload.name {
            self.name = payload.name
        }
        if self.phoneNumber != payload.phone {
            self.phoneNumber = payload.phone
        }
        if self.photoUrl != payload.photoURL {
            self.photoUrl = payload.photoURL
        }
        if self.pushToken != payload.pushToken {
            self.pushToken = payload.pushToken
        }
    }
}
