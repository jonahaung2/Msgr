//
//  Con+Ext.swift
//  Msgr
//
//  Created by Aung Ko Min on 22/11/22.
//

import Foundation
import CoreData
import GlobalNotificationSwift

extension Con {

    var title: String {
        get {
            return getContact()?.name ?? getGroupInfo()?.name ?? "No Name"
        }
        set {
            getGroupInfo()?.name = newValue
        }
    }

    var contact: Contact.Payload? {
        if let oneToOne = getContact() {
            return .init(oneToOne)
        }
        return nil
    }

    var members: [Contact.Payload] {
        if isGroup {
            if let groupInfo = getGroupInfo() {
                return groupInfo.getMembers().map { .init($0) }
            }
        } else {
            if let oneToOne = getContact() {
                return [CurrentUser.shared.payload, .init(oneToOne)]
            }
        }
        return []
    }

   

    class func incomingUnreadFetchRequest(for conId: String) -> NSFetchRequest<Msg> {
        let request = Msg.fetchRequest()
        let conPredicate = NSPredicate(format: "conId == %@", conId)
        let incomingPredicate = NSPredicate(format: "senderId != %@", CurrentUser.shared.id)
        let predicate = NSPredicate(format: "deliveryStatus_ != %i", Msg.DeliveryStatus.Read.rawValue)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [conPredicate, incomingPredicate, predicate])
        return request
    }

    class func outgoingUnreadFetchRequest(for conId: String) -> NSFetchRequest<Msg> {
        let request = Msg.fetchRequest()
        let conPredicate = NSPredicate(format: "conId == %@", conId)
        let incomingPredicate = NSPredicate(format: "senderId == %@", CurrentUser.shared.id)
        let predicate = NSPredicate(format: "deliveryStatus_ != %i", Msg.DeliveryStatus.Read.rawValue)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [conPredicate, incomingPredicate, predicate])
        return request
    }

    func incomingUnreadCount() -> Int {
        let context = Persistance.shared.viewContext
        let request = Con.incomingUnreadFetchRequest(for: self.id)
        request.resultType = .countResultType
        return (try? context.count(for: request)) ?? 0
    }

    static func allMsgsCount(for conId: String) -> Int {
        let context = Persistance.shared.viewContext
        let request = Msg.fetchRequest()
        request.predicate = NSPredicate(format: "conId == %@", conId)
        request.resultType = .countResultType
        return (try? context.count(for: request)) ?? 0
    }
}
