//
//  Con+.swift
//  Msgr
//
//  Created by Aung Ko Min on 27/10/22.
//

import SwiftUI

extension Con {

    enum ConType {
        case single(Contact?)
        case group([Contact])
    }
    var themeColor: ThemeColor {
        get { ThemeColor(rawValue: themeColor_) ?? .Blue }
        set { themeColor_ = newValue.rawValue }
    }
    
    func bubbleColor(for msg: Msg) -> Color {
        return msg.recieptType == .Send ? themeColor.color : bgImage == .None ? ChatKit.textBubbleColorIncomingPlain : ChatKit.textBubbleColorIncoming
    }

    var bgImage: BgImage {
        get { BgImage(rawValue: bgImage_) ?? .One }
        set { bgImage_ = newValue.rawValue }
    }

    var members: [Contact] {
        get {
            guard let members_ else {
                return []
            }
            var values = [Contact]()
            members_.forEach { mem in
                if let contact = Contact.find(for: mem) {
                    values.append(contact)
                }
            }
            return values
        }
        set {
            members_ = newValue.compactMap{ $0.id }
        }
    }
    var contact: Contact? {
        switch conType {
        case .single(let contact):
            return contact
        case .group:
            return nil
        }
    }
    var conType: ConType {
        let filtered = members.filter{ !$0.isCurrentUser }
        return filtered.count == 1 ? .single(filtered.first) : .group(filtered)
    }
}
