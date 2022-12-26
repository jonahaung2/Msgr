//
//  Msg+Ext.swift
//  Msgr
//
//  Created by Aung Ko Min on 22/10/22.
//

import SwiftUI

extension Msg {
    enum DeliveryStatus: Int16, CustomStringConvertible {
        case Sending, Sent, SendingFailed, Seen, Received, Read

        var description: String {
            switch self {
            case .Sending: return "Sending"
            case .Sent: return "Sent"
            case .SendingFailed: return "Failed"
            case .Seen: return "Seen"

            case .Received: return "Received"
            case .Read: return "Read"
            }
        }
        func iconName() -> String? {
            switch self {
            case .Sending: return "circlebadge"
            case .Sent: return "checkmark.circle.fill"
            case .SendingFailed: return "exclamationmark.circle.fill"
            case .Seen: return nil
            default: return nil
            }
        }
    }

    enum MsgType: Int16, Codable {
        case Text
        case Image
        case Video
        case Location
        case Emoji
        case Attachment
        case Voice
    }

    struct Reaction: Codable {
        let reaction: String
        let sender: Contact.Payload
    }
}
