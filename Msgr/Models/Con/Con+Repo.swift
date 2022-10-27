//
//  Con+Repo.swift
//  Msgr
//
//  Created by Aung Ko Min on 25/10/22.
//

import Foundation
import CoreData
extension Con {
    class func fetchOrCreate(contact: Contact) -> Con {
        let conId = contact.conId
        if let cCon = con(for: conId) {
            return cCon
        }
        let cCon = create(id: conId)
        cCon.name = contact.name

        return cCon
    }
    @discardableResult
    class func create(id: String) -> Con {
        let context = Persistence.shared.context
        let cCon = Con(context: context)
        cCon.id = id
        cCon.date = Date()
        return cCon
    }

    class func con(for id: String) -> Con? {
        let context = Persistence.shared.context
        let request: NSFetchRequest<Con> = Con.fetchRequest()
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

    class func delete(cCon: Con) {
        Persistence.shared.context.delete(cCon)
    }

    class func cons() -> [Con] {
        let context = Persistence.shared.context
        let request: NSFetchRequest<Con> = Con.fetchRequest()
        request.predicate = .init(format: "hasMsgs == %@", NSNumber(true))
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            return try context.fetch(request)
        }catch {
            print(error.localizedDescription)
            return []
        }
    }
    func lastMsg() -> Msg? {
        Msg.lastMsg(for: id.str)
    }
}
