//
//  Msg+Ext.swift
//  Msgr
//
//  Created by Aung Ko Min on 22/10/22.
//

import SwiftUI

extension Msg {

    enum DeliveryStatus: Int16, CustomStringConvertible {
        case Sending, Sent, SendingFailed, Received, Read
        var description: String {
            switch self {
            case .Sending: return "Sending"
            case .Sent: return "Sent"
            case .SendingFailed: return "Failed"
            case .Received: return "Received"
            case .Read: return "Read"
            }
        }
        func iconName() -> String? {
            switch self {
            case .Sending: return "circlebadge"
            case .Sent: return "checkmark.circle.fill"
            case .SendingFailed: return "exclamationmark.circle.fill"
            default: return nil
            }
        }
    }
}

extension Msg {
    enum RecieptType: Int16 {
        case Send
        case Receive
        var hAlignment: HorizontalAlignment { self == .Send ? .trailing : .leading }
    }
}

extension Msg {
    enum MsgType: Int16 {
        case Text
        case Image
        case Video
        case Location
        case Emoji
        case Attachment
        case Voice
    }
}
