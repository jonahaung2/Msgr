//
//  Con+.swift
//  Msgr
//
//  Created by Aung Ko Min on 27/10/22.
//

import SwiftUI

extension Con {

    enum ConType {
        case single(Contact.Payload)
        case group([Contact.Payload])
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

    var contactPayload: Contact.Payload? {
        members.filter{ $0.id != CurrentUser.id }.first
    }
    
    var members: [Contact.Payload] {
        get {
            guard let members_ else { return [] }
            var values = [Contact.Payload]()
            members_.forEach { mem in
                if let x = MessageCachingUtils.shared.userDisplayInfo(with: mem) {
                    values.append(x)
                }else if let contact = Contact.find(for: mem) {
                    values.append(.init(contact))
                }
            }
            return values
        }
        set {
            members_ = newValue.compactMap{ $0.id }
        }
    }

    var conType: ConType {
        let filtered = members.filter{ $0.id != CurrentUser.id }
        guard !filtered.isEmpty else {
            return .single(.init(id: "", name: "", phone: "", photoURL: ""))
        }
        return filtered.count == 1 ? .single(filtered[0]) : .group(filtered)
    }

    var nameX: String {
        switch conType {
        case .single(let x):
            return x.name
        case .group(let members):
            return name ?? members.prefix(3).compactMap{ $0.name.first }.map{ String($0) }.joined(separator: ", ")
        }
    }
}
