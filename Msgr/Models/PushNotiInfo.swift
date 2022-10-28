//
//  PushNotiInfo.swift
//  Msgr
//
//  Created by Aung Ko Min on 28/10/22.
//

import Foundation
import UserNotifications

public class PushNotiInfo {

    public let cid: String?
    public let messageId: String?
    public let eventType: EventType?
    public let custom: [String: String]?

    public init(content: UNNotificationContent) throws {
        guard let payload = content.userInfo["stream"], let dict = payload as? [String: String] else {
            throw fatalError("missing stream key or not a [string:string] dict")
        }

        guard let type = dict["type"] else {
            throw fatalError("missing stream.type key")
        }

        eventType = EventType(rawValue: type)

        if let cid = dict["cid"] {
            self.cid = cid
        } else {
            cid = nil
        }

        if EventType.messageNew.rawValue == type, let id = dict["id"] {
            messageId = id
        } else {
            messageId = nil
        }

        custom = dict.removingValues(forKeys: ["cid", "type", "id"])
    }
}

extension Dictionary {
    func mapKeys<TransformedKey: Hashable>(_ transform: (Key) -> TransformedKey) -> [TransformedKey: Value] {
        .init(uniqueKeysWithValues: map { (transform($0.key), $0.value) })
    }

    @discardableResult
    mutating func removeValues(forKeys keys: [Key]) -> [Value?] {
        keys.map { removeValue(forKey: $0) }
    }

    func removingValues(forKeys keys: [Key]) -> Self {
        var result = self
        result.removeValues(forKeys: keys)
        return result
    }
}
