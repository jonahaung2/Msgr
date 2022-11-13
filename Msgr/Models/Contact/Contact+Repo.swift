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
        return [id, currentUserId].sorted().joined()
    }

    func con() -> Con {
        Con.fetchOrCreate(contact: self)
    }

    class func find(for id: String) -> Contact? {
        let context = CoreDataStack.shared.viewContext
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
        let context = CoreDataStack.shared.viewContext
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
        let context = CoreDataStack.shared.viewContext
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
        CoreDataStack.shared.viewContext.delete(cContact)
    }
}
