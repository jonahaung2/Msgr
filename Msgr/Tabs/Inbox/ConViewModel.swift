//
//  ConViewModel.swift
//  Msgr
//
//  Created by Aung Ko Min on 4/11/22.
//

import SwiftUI

final class ConViewModel: ObservableObject {

    var con: Con

    var id: String {
        con.id.str
    }
    var name: String {
        con.name.str
    }
    var hasMsgs: Bool {
        get { con.hasMsgs }
        set { con.hasMsgs = newValue }
    }

    var cellSpacing: CGFloat {
        get { con.cellSpacing.cgFloat }
        set {
            con.cellSpacing = Int16(newValue)
        }
    }

    var bubbleCornorRadius: CGFloat {
        get { con.bubbleCornorRadius.cgFloat }
        set { con.bubbleCornorRadius = Int16(newValue) }
    }

    var themeColor: Con.ThemeColor {
        get { con.themeColor }
        set { con.themeColor = newValue }
    }

    var bgImage: Con.BgImage {
        get { con.bgImage }
        set { con.bgImage = newValue }
    }

    var members: [Contact_] {
        get {
            con.members
        }
        set {
            con.members = newValue
        }
    }
    var contact_: Contact_? {
        members.filter{ $0.id != CurrentUser.id }.first
    }

    lazy var lasMsg: Msg? = { [weak self] in
        return self?.con.lastMsg()
    }()

    func bubbleColor(for msg: Msg) -> Color {
        return msg.recieptType == .Send ? themeColor.color : bgImage == .None ? ChatKit.textBubbleColorIncomingPlain : ChatKit.textBubbleColorIncoming
    }


    

    init(con: Con) {
        self.con = con
    }

    convenience init(contact: Contact) {
        self.init(con: contact.con())
    }
}
