//
//  ConViewModel.swift
//  Msgr
//
//  Created by Aung Ko Min on 4/11/22.
//

import SwiftUI

class InboxCellViewModel: ObservableObject, Identifiable, Equatable {

    static func == (lhs: InboxCellViewModel, rhs: InboxCellViewModel) -> Bool {
        lhs.id == rhs.id && lhs.msg == rhs.msg && lhs.unreadCount == rhs.unreadCount
    }

    var id: String { msg.id  }
    var msg: Msg
    var sender: Contact.Payload
    var conId: String { msg.conId }
    var title: String
    var photoURL: String
    var text: String { msg.text ?? ""}
    var date: Date { msg.date }
    var unreadCount: Int
    var hasUnreadMsgs: Bool { unreadCount > 0 }
    var senderName: String { sender.name }

    init?(msg: Msg) {
        guard let con = msg.lastCon, let sender = msg.sender else { return nil }
        self.msg = msg
        self.sender = .init(sender)
        self.title = con.title
        self.unreadCount = con.incomingUnreadCount()
        self.photoURL = con.isGroup ? (con.getGroupInfo()?.photoUrl ?? "") : (con.getContact()?.photoUrl ?? "")
    }
}
