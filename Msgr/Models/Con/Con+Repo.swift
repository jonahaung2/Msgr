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
        let context = CoreDataStack.shared.viewContext
        let con = Con(context: context)
        con.id = conId
//        con.name = contact.name
        con.members_ = [CurrentUser.id, contact.id.str]
//        con.photoUrl = contact.photoUrl ?? "https://media-exp1.licdn.com/dms/image/C5603AQEmuML1GXI9DQ/profile-displayphoto-shrink_800_800/0/1630504470059?e=1672272000&v=beta&t=lAsZRcQIW79CdEN3Fps8WTRGuotjMBN8c1PSttvOsWo"
        con.date = Date()
        return con
    }


    class func con(for id: String) -> Con? {
        let context = CoreDataStack.shared.viewContext
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
        CoreDataStack.shared.viewContext.delete(cCon)
    }

    class func cons() -> [Con] {
        let context = CoreDataStack.shared.viewContext
        let request = Con.fetchRequest()
//        request.predicate = .init(format: "hasMsgs == %@", NSNumber(true))
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
