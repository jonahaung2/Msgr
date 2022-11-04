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
        let context = PersistentContainer.shared.viewContext
        let con = Con(context: context)
        con.id = conId
        con.name = contact.name
        con.members_ = [CurrentUser.id, contact.id.str]
        con.photoUrl = Media.path(userId: contact.id.str)
        con.date = Date()
        return con
    }


    class func con(for id: String) -> Con? {
        let context = PersistentContainer.shared.viewContext
        let request = Con.fetchRequest(keyPath: "id", equalTo: id)
        request.fetchLimit = 1
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    class func delete(cCon: Con) {
        PersistentContainer.shared.viewContext.delete(cCon)
    }

    class func cons() -> [Con] {
        let context = PersistentContainer.shared.viewContext
        let request = Con.fetchRequest()
        request.predicate = .init(format: "hasMsgs == %@", NSNumber(true))
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
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
