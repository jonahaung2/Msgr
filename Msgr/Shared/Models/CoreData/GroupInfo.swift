//
//  GroupInfo+CoreDataProperties.swift
//  Msgr
//
//  Created by Aung Ko Min on 15/12/22.
//
//

import Foundation
import CoreData
import FirebaseFirestore
import FirebaseFirestoreSwift

@objc(GroupInfo)
public class GroupInfo: NSManagedObject {}

extension GroupInfo: Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GroupInfo> {
        return NSFetchRequest<GroupInfo>(entityName: "GroupInfo")
    }

    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var photoUrl: String
    @NSManaged public var created: Date?
    @NSManaged public var membersArray: String
    @NSManaged public var adminsArray: String
    @NSManaged public var createdByID: String

    var members_: [String] {
        get {
            membersArray.components(separatedBy: " ")
        }
        set {
            membersArray = newValue.joined(separator: " ")
        }
    }
    var admins_: [String] {
        get {
            adminsArray.components(separatedBy: " ")
        }
        set {
            adminsArray = newValue.joined(separator: " ")
        }
    }

    func getMembers() -> [Contact] {
        let context = managedObjectContext ?? Persistance.shared.viewContext
        return members_.compactMap{ Contact.object(for: $0, context) }.sorted { $0.name > $1.name }
    }
    func getAdmins() -> [Contact] {
        let context = managedObjectContext ?? Persistance.shared.viewContext
        return admins_.compactMap{ Contact.object(for: $0, context) }.sorted { $0.name > $1.name }
    }

    var createdBy: Contact? { Contact.object(for: createdByID, managedObjectContext ?? Persistance.shared.viewContext) }
}

extension GroupInfo {
    struct Payload: Cachable {
        let id: String
        let name: String
        let photoUrl: String
        let created: Double
        let createdBy: String
        let members: [String]
        let admins: [String]
    }
}

extension GroupInfo.Payload {
    init(id: String) {
        self.init(id: id, name: "A Group", photoUrl: "", created: 0, createdBy: "", members: [], admins: [])
    }
}

extension GroupInfo.Payload {

    init(_ info: GroupInfo) {
        self.init(id: info.id, name: info.name, photoUrl: info.photoUrl, created: info.created?.timeIntervalSince1970 ?? Date.now.timeIntervalSince1970, createdBy: info.createdByID, members: info.members_, admins: info.admins_)
    }
}
extension GroupInfo {

    @discardableResult
    convenience init?(payload: GroupInfo.Payload, context: NSManagedObjectContext) async throws {
        if let obj = GroupInfo.object(for: payload.id, context) {
            obj.sync(with: payload)
            return nil
        }
        self.init(context: context)
        self.sync(with: payload)
    }
}

extension GroupInfo {
    @discardableResult
    static func fetchOrCreate(from id: String, _  context: NSManagedObjectContext) async throws -> GroupInfo {
        if let existing = Self.object(for: id, context) {
            return existing
        }
        let payload = try await self.fetchRemotePayload(id: id)
        let groupInfo = GroupInfo(context: context)
        groupInfo.sync(with: payload)
        return groupInfo
    }

    @discardableResult
    static func save(_ payload: GroupInfo.Payload, context: NSManagedObjectContext) -> GroupInfo {
        if let existing = Self.object(for: payload.id, context) {
            existing.sync(with: payload)
            return existing
        }
        let groupInfo = GroupInfo(context: context)
        groupInfo.sync(with: payload)
        return groupInfo
    }


    func sync(with payload: GroupInfo.Payload) {
        if self.id != payload.id { self.id = payload.id }
        if self.name != payload.name { self.name = payload.name }
        if self.photoUrl != payload.photoUrl { self.photoUrl = payload.photoUrl }
        let createdDate = Date(timeIntervalSince1970: payload.created).convert(from: .singapore, to: .current)
        if self.created != createdDate { self.created = createdDate }
        if self.createdByID != payload.createdBy { self.createdByID = payload.createdBy }
        if self.admins_ != payload.admins { self.admins_ = payload.admins }
        if self.members_ != payload.members { self.members_ = payload.members }
    }

    func fetchContacts(ids: [String], _ context: NSManagedObjectContext) async throws -> [Contact] {
        return try await withThrowingTaskGroup(of: Contact.self) { group in
            var contacts = [Contact]()
            contacts.reserveCapacity(ids.count)
            for id in ids {
                group.addTask {
                    return try await Contact.fetchOrCreate(from: id, context)
                }
            }

            for try await contact in group {
                contacts.append(contact)
            }
            return contacts
        }
    }

    static func fetchRemotePayload(id: String) async throws -> GroupInfo.Payload {
        return try await Firestore.firestore().collection("groups")
            .document(id)
            .getDocument()
            .data(as: GroupInfo.Payload.self)
    }
}
