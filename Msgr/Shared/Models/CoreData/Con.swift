//
//  Con+CoreDataProperties.swift
//  Msgr
//
//  Created by Aung Ko Min on 30/11/22.
//
//

import Foundation
import CoreData
import FirebaseFirestore
import FirebaseFirestoreSwift

@objc(Con)
public class Con: NSManagedObject {

}

extension Con: Identifiable {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Con> {
        return NSFetchRequest<Con>(entityName: "Con")
    }

    @NSManaged public var bgImage_: Int16
    @NSManaged public var bubbleCornorRadius: Int16
    @NSManaged public var cellSpacing: Int16
    @NSManaged public var id: String
    @NSManaged public var themeColor_: Int16
    @NSManaged public var lastMsg: Msg?
    @NSManaged public var msgs: NSSet?
    @NSManaged public var oneToOneID: String?

    var isGroup: Bool { oneToOneID == nil }
    func getGroupInfo() -> GroupInfo? {
        guard self.isGroup else { return nil }
        return GroupInfo.object(for: id, Persistance.shared.viewContext)
    }

    func getContact() -> Contact? {
        guard !self.isGroup, let oneToOneID else { return nil }
        return Contact.object(for: oneToOneID, managedObjectContext ?? Persistance.shared.viewContext)
    }
}

// MARK: Generated accessors for msgs
extension Con {

    @objc(addMsgsObject:)
    @NSManaged public func addToMsgs(_ value: Msg)

    @objc(removeMsgsObject:)
    @NSManaged public func removeFromMsgs(_ value: Msg)

    @objc(addMsgs:)
    @NSManaged public func addToMsgs(_ values: NSSet)

    @objc(removeMsgs:)
    @NSManaged public func removeFromMsgs(_ values: NSSet)

}

extension Con {

    @discardableResult
    class func fetchOrCreate(conId: String, context: NSManagedObjectContext) -> Con {
        if let con = Con.object(for: conId, context) {
            return con
        }
        let ids = conId.components(separatedBy: " ")
        let isOneToOne = ids.count == 2 && ids.contains(CurrentUser.shared.id)
        let con = Con(context: context)
        con.id = conId
        if isOneToOne {
            let filtered = ids.filter{ $0 != CurrentUser.shared.id }
            if let oneToOneID = filtered.last, !oneToOneID.isEmpty {
                con.oneToOneID = oneToOneID
            }
        } else {
            
        }
        return con
    }
}
