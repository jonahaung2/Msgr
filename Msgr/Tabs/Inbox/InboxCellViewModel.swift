//
//  ConViewModel.swift
//  Msgr
//
//  Created by Aung Ko Min on 4/11/22.
//

import SwiftUI

struct InboxCellViewModel: Identifiable, Equatable {
    
    var id: String { con.id.str }
    let con: Con
    let lastMsg: Msg
    let msgCount: Int

    init(con: Con, lastMsg: Msg) {
        self.con = con
        self.lastMsg = lastMsg
        self.msgCount = Msg.count(for: con.id.str)
    }

    static func == (lhs: InboxCellViewModel, rhs: InboxCellViewModel) -> Bool {
        lhs.id == rhs.id && lhs.con == rhs.con && lhs.lastMsg == rhs.lastMsg
    }
}
