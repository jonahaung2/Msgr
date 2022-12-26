//
//  Con+.swift
//  Msgr
//
//  Created by Aung Ko Min on 27/10/22.
//

import SwiftUI

extension Con {

    var themeColor: ThemeColor {
        get { ThemeColor(rawValue: themeColor_) ?? .Blue }
        set { themeColor_ = newValue.rawValue }
    }
    
    func bubbleColor(for msg: Msg) -> Color {
        return msg.isSender ? themeColor.color : bgImage == .None ? ChatKit.textBubbleColorIncomingPlain : ChatKit.textBubbleColorIncoming
    }

    var bgImage: BgImage {
        get { BgImage(rawValue: bgImage_) ?? .One }
        set { bgImage_ = newValue.rawValue }
    }


//    var members: [Contact.Payload] {
//        get {
//            var items = [Contact.Payload]()
//            self.members_.forEach { id in
//                if let item = MessageCachingUtils.shared.contactPayload(id: id) {
//                    items.append(item)
//                }
//            }
//            return items
//        }
//        set {
//            members_ = newValue.compactMap{ $0.id }
//        }
//    }

//    var contact: Contact? {
//        guard !isGroup else {
//            return nil
//        }
//        let ids = members_
//        guard ids.count == 2 else {
//            return nil
//        }
//        let contactId = ids.filter{ $0 != CurrentUser.shared.id }.first ?? ""
//        return Contact.contact(for: contactId, context: CoreDataStack.shared.viewContext)
//    }

//    var title: String {
//        get {
//            if isGroup {
//                return name ?? members.prefix(3).compactMap{ $0.name.first }.map{ String($0) }.joined(separator: ", ")
//            } else {
//                return contact?.name ?? "No Name"
//            }
//        }
//        set {
//            if isGroup {
//                name = newValue
//            } else {
//
//            }
//        }
//    }
//
//    var conProfileUrl: String? {
//        if isGroup {
//            return "https://media-exp1.licdn.com/dms/image/C5603AQEmuML1GXI9DQ/profile-displayphoto-shrink_800_800/0/1630504470059?e=1672272000&v=beta&t=lAsZRcQIW79CdEN3Fps8WTRGuotjMBN8c1PSttvOsWo"
//        } else {
//            return contact?.photoUrl
//        }
//    }
}
