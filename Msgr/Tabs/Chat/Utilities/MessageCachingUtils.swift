//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation

protocol Cachable: Codable, Identifiable, Hashable {}

class MessageCachingUtils {

    private var cache = [String: any Cachable]()
    
    func contactPayload(id: String) -> Contact.Payload? {
        if let old = cache[id] as? Contact.Payload {
            return old
        }
        if let contact = Contact.object(for: id, Persistance.shared.viewContext) {
            let payload = Contact.Payload(contact)
            cache[id] = payload
            return payload
        }
        return nil
    }

    func groupPayload(id: String) -> GroupInfo.Payload? {
        if let old = cache[id] as? GroupInfo.Payload {
            return old
        }
        if let contact = GroupInfo.object(for: id, Persistance.shared.viewContext) {
            let payload = GroupInfo.Payload(contact)
            cache[id] = payload
            return payload
        }
        return nil
    }

    func update(_ items: [any Cachable]) {
        items.forEach { item in
            cache[item.id as! String] = item
        }
    }

    func clearCache() {
        cache.removeAll()
    }
}
