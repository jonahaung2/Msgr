//
//  AnyMsg.swift
//  Msgr
//
//  Created by Aung Ko Min on 9/12/22.
//

import Foundation

struct AnyNoti: Codable {

    let notiType: AnyNotiType
    // Type
    enum AnyNotiType: Codable {
        case msg(type: MsgNotiType)
        case conNoti(type: ConNotiType)
        // Msg
        enum MsgNotiType: Codable {
            case newMsg(payload: Msg.Payload)
            case reaction(reaction: Msg.Reaction)
        }
        // Con
        enum ConNotiType: Codable {
            case typing(by: Typing)
            struct Typing: Codable {
                let conId: String
                let isTyping: Bool
                let sender: Contact.Payload
            }
        }
    }
}

extension AnyNoti {
    static func noti(from userInfo: [AnyHashable: Any]) -> AnyNoti? {
        guard
            let msgString = userInfo["noti"] as? String,
            let data = msgString.data(using: .utf8)
        else { return nil }
        do {
           return try JSONDecoder().decode(AnyNoti.self, from: data)
        } catch {
            Log(error)
            return nil
        }
    }
}
