//
//  Msg.Payload.swift
//  Msgr
//
//  Created by Aung Ko Min on 12/11/22.
//

import Foundation

extension Msg {
    struct Payload: Codable {
        let id: String
        let text: String
        let date: Date
        let conId: String
        let senderId: String
        let msgType: Int16
    }
}

extension Msg.Payload {
    static func msgPayload(from userInfo: [AnyHashable: Any]) -> Msg.Payload? {
        guard
            let msgString = userInfo["msg"] as? String,
            let data = msgString.data(using: .utf8)
        else { return nil }
        do {
           return try JSONDecoder().decode(Msg.Payload.self, from: data)
        } catch {
            print(error)
            return nil
        }
    }
}
