//
//  Contact+CoreDataProperties.swift
//  Msgr
//
//  Created by Aung Ko Min on 30/11/22.
//
//

import Foundation
import CoreData
import FirebaseFirestore
import FirebaseFirestoreSwift

@objc(Contact)
public class Contact: NSManagedObject {}

extension Contact: Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact")
    }
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var phoneNumber: String?
    @NSManaged public var photoUrl: String?
    @NSManaged public var lastSeen: Date?
    @NSManaged public var pushToken: String?
    @NSManaged public var msgs: NSSet?
    @NSManaged public var cons_: NSSet?

}


// MARK: Generated accessors for msgs
extension Contact {
    @objc(addMsgsObject:)
    @NSManaged public func addToMsgs(_ value: Msg)
    @objc(removeMsgsObject:)
    @NSManaged public func removeFromMsgs(_ value: Msg)
    @objc(addMsgs:)
    @NSManaged public func addToMsgs(_ values: NSSet)
    @objc(removeMsgs:)
    @NSManaged public func removeFromMsgs(_ values: NSSet)
}

// MARK: Generated accessors for cons_
extension Contact {
    @objc(addCons_Object:)
    @NSManaged public func addToCons_(_ value: Con)
    @objc(removeCons_Object:)
    @NSManaged public func removeFromCons_(_ value: Con)
    @objc(addCons_:)
    @NSManaged public func addToCons_(_ values: NSSet)
    @objc(removeCons_:)
    @NSManaged public func removeFromCons_(_ values: NSSet)
}

extension Contact {

    internal static func conId(from contactId: String) -> String {
        let currentUserId = CurrentUser.shared.id
        guard contactId != currentUserId else {
            return contactId
        }
        return [contactId, currentUserId].sorted().joined(separator: " ")
    }

    var isCurrentUser: Bool { id == CurrentUser.shared.id }
    var conId: String { Self.conId(from: id)}

    class func fecthAll() -> [Contact] {
        let context = Persistance.shared.viewContext
        let request = Contact.fetchRequest()
        do {
            let results = try context.fetch(request)
            return results
        } catch {
            Log(error.localizedDescription)
            return []
        }
    }
}

extension Contact {

    struct Payload: Cachable {
        var id: String
        var name: String
        var phone: String
        var photoURL: String
        var pushToken: String?
        var lastSeen: Date?

        var lastSeenLocalized: Date? {
            guard let lastSeen else { return nil }
            return lastSeen.convert(from: .singapore, to: .current)
        }
        var conId: String { Contact.conId(from: id) }
    }
}

extension Contact.Payload {

    init(id: String) {
        self.init(id: id, name: "A Person", phone: "", photoURL: "")
    }
}

extension Contact.Payload {
    init(_ contact: Contact) {
        self.init(id: contact.id, name: contact.name, phone: contact.phoneNumber ?? "", photoURL: contact.photoUrl.str, pushToken: contact.pushToken, lastSeen: contact.lastSeen)
    }
}

internal extension Contact {

    @discardableResult
    static func fetchOrCreate(from id: String, _  context: NSManagedObjectContext) async throws -> Contact {
        if let existing = Self.object(for: id, context) {
            return existing
        }
        let payload = try await self.fetchRemotePayload(id: id)
        return Contact.save(payload, context: context)
    }

    @discardableResult
    static func save(_ payload: Contact.Payload, context: NSManagedObjectContext) -> Contact {
        if let existing = Self.object(for: payload.id, context) {
            existing.sync(with: payload)
            return existing
        }
        let obj = Contact(context: context)
        obj.sync(with: payload)
        return obj
    }

    func sync(with payload: Contact.Payload) {
        if self.id != payload.id { self.id = payload.id }
        if self.name != payload.name { self.name = payload.name }
        if self.phoneNumber != payload.phone { self.phoneNumber = payload.phone }
        if self.photoUrl != payload.photoURL { self.photoUrl = payload.photoURL }
        if self.pushToken != payload.pushToken { self.pushToken = payload.pushToken }
        if self.lastSeen != payload.lastSeenLocalized { self.lastSeen = payload.lastSeenLocalized }
    }

    static func fetchRemotePayload(id: String) async throws -> Contact.Payload {
        return try await Firestore.firestore()
            .collection("users")
            .document(id)
            .getDocument()
            .data(as: Contact.Payload.self)
    }

    static func fetchRemotePayload(id: String, _ completion: @escaping (Contact.Payload?)  -> Void ) {
        Firestore.firestore()
            .collection("users")
            .document(id)
            .getDocument { snapshot, error in
                if let snapshot {
                    let item = try? snapshot.data(as: Contact.Payload.self)
                    completion(item)
                } else {
                    completion(nil)
                }
            }
    }
}
