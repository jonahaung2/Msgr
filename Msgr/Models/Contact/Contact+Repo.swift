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
        let currentUser = CurrentUser.shared.user
        return id > currentUser.id.str ? currentUser.id.str + id : id + currentUser.id.str
    }
    func con() -> Con {
        Con.fetchOrCreate(contact: self)
    }

    convenience init(id: String, name: String, phoneNumber: String, photoUrl: String) {
        self.init(context: Persistence.shared.context)
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.photoUrl = photoUrl

    }

    convenience init(phContact: PhoneContact) {
        self.init(context: Persistence.shared.context)
        self.id = phContact.phoneNumber.first.str
        self.name = phContact.name.str
        self.phoneNumber = phContact.phoneNumber.first ?? ""
        if let data = phContact.avatarData {
            Media.save(userId: self.id.str, data: data)
            photoUrl = Media.path(userId: phContact.id)
        }
    }
    convenience init(phoneNumber: String, name: String) {
        self.init(context: Persistence.shared.context)
        self.id = phoneNumber
        self.name = name
        self.phoneNumber = phoneNumber
    }
    class func find(for id: String) -> Contact? {
        let context = Persistence.shared.context
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

    class func fecthOrCreate(for phoneContact: PhoneContact) -> Contact {
        if let x = find(for: phoneContact.id) {
            return x
        } else {
            return Contact(phContact: phoneContact)
        }
    }

    class func hasSaved(for id: String) -> Bool {
        let context = Persistence.shared.context
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
        let context = Persistence.shared.context
        let request = Contact.fetchRequest()
//        request.predicate = .init(format: "id == %@", id)
        do {
            let results = try context.fetch(request)
            return results
        } catch {
            print(error.localizedDescription)
            return []
        }
    }

    class func delete(cContact: Contact) {
        Persistence.shared.context.delete(cContact)
    }
}
