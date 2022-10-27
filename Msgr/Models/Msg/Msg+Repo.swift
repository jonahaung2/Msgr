//
//  MsgRepo.swift
//  Msgr
//
//  Created by Aung Ko Min on 22/10/22.
//

import Foundation

extension Msg {
    static var cached = FetchCache()
    static func create(text: String, conId: String, senderId: String) -> Msg {
        let context = Persistence.shared.context
        let x = Msg(context: context)
        x.id = UUID().uuidString
        x.text = text
        x.conId = conId
        x.senderId = senderId
        x.date = Date()
        
        return x
    }

    class func msg(for id: String) -> Msg? {
        let context = Persistence.shared.context
        let request = Msg.fetchRequest()
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

    class func delete(id: String) -> Bool {
        let context = Persistence.shared.context
        guard let msg = self.msg(for: id) else { return false }
        context.delete(msg)
        return true
    }

    class func count(for conId: String) -> Int {
        let context = Persistence.shared.context
        let request = Msg.fetchRequest()
        request.predicate = NSPredicate(format: "conId == %@", conId)
        request.resultType = .countResultType
        return (try? context.count(for: request)) ?? 0
    }
//    class func msgs(for conId: String, limit: Int, offset: Int) -> [Msg] {
//        let context = Persistence.shared.context
//        context.refreshAllObjects()
//        let request = Msg.fetchRequest()
//        request.predicate = NSPredicate(format: "conId == %@", conId)
//        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
//        request.fetchLimit = limit
//        request.fetchOffset = offset
//        do {
//            return try context.fetch(request)
//        }catch {
//            print(error.localizedDescription)
//            return []
//        }
//    }
    class func lastMsg(for conId: String) -> Msg? {
        let context = Persistence.shared.context
        let request = Msg.fetchRequest()
        request.predicate = NSPredicate(format: "conId == %@", conId)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 1
        do {
            return try context.fetch(request).first
        }catch {
            print(error.localizedDescription)
            return nil
        }
    }

    class func msgs(for conId: String) -> [Msg] {
        let context = Persistence.shared.context
        let request = Msg.fetchRequest()
        request.predicate = NSPredicate(format: "conId == %@", conId)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            return try context.fetch(request)
        }catch {
            print(error.localizedDescription)
            return []
        }
    }
}
