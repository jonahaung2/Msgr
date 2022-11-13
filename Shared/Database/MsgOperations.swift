//
//  MsgOperations.swift
//  Msgr
//
//  Created by Aung Ko Min on 6/11/22.
//

import Foundation
import CoreData
import GlobalNotificationSwift

class MsgCreateOperation: Operation {
    private let payload: Msg.Payload
    private let context: NSManagedObjectContext
    private let informSavedNotification: Bool
    init(payload: Msg.Payload, context: NSManagedObjectContext, informSavedNotification: Bool) {
        self.payload = payload
        self.context = context
        self.informSavedNotification = informSavedNotification
    }
    override func main() {
        if self.isCancelled { return }
        let backgroundContext = self.context
        let entity = Msg.entity()
        let object = NSManagedObject(entity: entity, insertInto: backgroundContext)
        object.setValue(payload.id, forKey: "id")
        object.setValue(payload.conId, forKey: "conId")
        object.setValue(payload.senderId, forKey: "senderId")
        object.setValue(payload.text, forKey: "text")
        object.setValue(payload.date, forKey: "date")
        object.setValue(payload.msgType, forKey: "msgType_")
        backgroundContext.insert(object)
        NSManagedObjectContext.sync(context: backgroundContext)
        if informSavedNotification {
            LocalNotifications.postMsg(payload: payload)
        }
    }
}

class ContactCreateOperation: Operation {
    private let payload: Contact.Payload
    private let context: NSManagedObjectContext
    init(payload: Contact.Payload, context: NSManagedObjectContext) {
        self.payload = payload
        self.context = context
    }
    override func main() {
        if self.isCancelled { return }
        let backgroundContext = self.context
        let entity = Contact.entity()
        let object = NSManagedObject(entity: entity, insertInto: backgroundContext)
        object.setValue(payload.id, forKey: "id")
        object.setValue(payload.phone, forKey: "phoneNumber")
        object.setValue(payload.name, forKey: "name")
        object.setValue(payload.photoURL, forKey: "photoUrl")
        object.setValue(payload.pushToken, forKey: "pushToken")
        backgroundContext.insert(object)
        NSManagedObjectContext.sync(context: backgroundContext)
        GlobalNotificationCenter.shared.postNotification(.init(GroupContainer.appGroupId+".contact.didSave"))
    }
}
