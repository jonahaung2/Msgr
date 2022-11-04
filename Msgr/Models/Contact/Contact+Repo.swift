//
//  Contact+Repo.swift
//  Msgr
//
//  Created by Aung Ko Min on 25/10/22.
//

import Foundation
import CoreData

extension Contact {

    var conId: String {
        guard let id = self.id else { fatalError() }
        let currentUserId = CurrentUser.id
        return id > currentUserId ? currentUserId : id + currentUserId
    }
    func con() -> Con {
        Con.fetchOrCreate(contact: self)
    }

    convenience init(id: String, name: String, phoneNumber: String, photoUrl: String, pushToken: String?) {
        self.init(context: PersistentContainer.shared.viewContext)
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.photoUrl = photoUrl
        self.pushToken = pushToken
    }

    class func fetchOrCreate(contact_: Contact_) {
        if !hasSaved(for: contact_.id) {
            _ = Contact.init(id: contact_.id, name: contact_.name, phoneNumber: contact_.phone, photoUrl: contact_.photoURL.str, pushToken: contact_.pushToken)
        }
    }

    convenience init(phoneNumber: String, name: String) {
        self.init(context: PersistentContainer.shared.viewContext)
        self.id = phoneNumber
        self.name = name
        self.phoneNumber = phoneNumber
    }

    class func find(for id: String) -> Contact? {
        let context = PersistentContainer.shared.viewContext
        let request = Contact.fetchRequest()
        request.fetchLimit = 1
        request.predicate = .init(format: "id == %@", id)
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    class func hasSaved(for id: String) -> Bool {
        let context = PersistentContainer.shared.viewContext
        let request = Contact.fetchRequest()
        request.resultType = .countResultType
        request.fetchLimit = 1
        request.predicate = .init(format: "id == %@", id)
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    class func fecthAll() -> [Contact] {
        let context = PersistentContainer.shared.viewContext
        let request = Contact.fetchRequest()
        do {
            let results = try context.fetch(request)
            return results
        } catch {
            print(error.localizedDescription)
            return []
        }
    }

    class func delete(cContact: Contact) {
        PersistentContainer.shared.viewContext.delete(cContact)
    }
}
