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
        return id > CurrentUser.shared.user.id ? CurrentUser.shared.user.id + id : id + CurrentUser.shared.user.id
    }
    func con() -> Con {
        Con.fetchOrCreate(contact: self)
    }



    convenience init(phContact: PhoneContact) {
        self.init(context: Persistence.shared.context)
        self.id = phContact.phoneNumber.first ?? ""
        self.name = phContact.name ?? ""
        self.phoneNumber = phContact.phoneNumber.first ?? ""
        if let data = phContact.avatarData {
            Media.save(userId: phContact.id, data: data)
        }
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
        if hasSaved(for: phoneContact.id), let x = find(for: phoneContact.id) {
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
