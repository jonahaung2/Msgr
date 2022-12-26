//
//  ConversationKind.swift
//  Msgr
//
//  Created by Aung Ko Min on 25/12/22.
//

import Foundation

enum ConversationKind {
    
    case OneToOne(Contact.Payload)
    case Group(GroupInfo.Payload)
    case Deleted

    var title: String {
        switch self {
        case .OneToOne(let x):
            return x.name
        case .Group(let x):
            return x.name
        case .Deleted:
            return "Deleted"
        }
    }

    var subtitle: String {
        switch self {
        case .OneToOne(let x):
            if let date = x.lastSeenLocalized {
                return date.toString(dateStyle: .short, timeStyle: .short, isRelative: true) ?? ""
            } else {
                return "Active"
            }
        case .Group(let x):
            return "\(x.members.count) members"
        case .Deleted:
            return ""
        }
    }
}
