//
//  Msg+CoreDataProperties.swift
//  Msgr
//
//  Created by Aung Ko Min on 30/11/22.
//
//

import Foundation
import CoreData

@objc(Msg)
public class Msg: NSManagedObject {}

extension Msg: Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Msg> {
        return NSFetchRequest<Msg>(entityName: "Msg")
    }

    @NSManaged public var conId: String
    @NSManaged public var senderId: String
    @NSManaged public var date: Date
    @NSManaged public var deliveryStatus_: Int16
    @NSManaged public var id: String
    @NSManaged public var msgType_: Int16
    @NSManaged public var progress: Int16
    @NSManaged public var text: String?
    @NSManaged public var isSender: Bool

    @NSManaged public var con: Con?
    @NSManaged public var lastCon: Con?
    @NSManaged public var sender: Contact?

    var msgType: MsgType {
        get { .init(rawValue: msgType_) ?? .Text }
        set { msgType_ = newValue.rawValue }
    }
    var deliveryStatus: DeliveryStatus {
        get { .init(rawValue: deliveryStatus_) ?? .Sent }
        set { deliveryStatus_ = newValue.rawValue }
    }
}


extension Msg {

    @discardableResult
    static func save(payload: Msg.Payload, _ context: NSManagedObjectContext) -> Msg {
        if let msg = Msg.object(for: payload.id, context) {
            return msg
        }
        let msg = Msg(context: context)
        msg.id = payload.id
        msg.conId = payload.conID
        msg.senderId = payload.senderID
        msg.date = payload.date.convert(from: .singapore, to: .current)
        msg.isSender = payload.senderID == CurrentUser.shared.id

        switch payload.content {
        case .Text(let text):
            msg.text = text
            msg.msgType = .Text
        case .Image:
            msg.msgType = .Image
        case .Video:
            msg.msgType = .Video
        case .Location:
            msg.msgType = .Location
        case .Emoji:
            msg.msgType = .Emoji
        case .Attachment:
            msg.msgType = .Attachment
        case .Voice:
            msg.msgType = .Voice
        }

        let con = Con.fetchOrCreate(conId: payload.conID, context: context)
        msg.con = con
        msg.lastCon = con
        msg.sender = {
            if let obj = Contact.object(for: payload.senderID, context) {
                return obj
            }
            if payload.senderID == CurrentUser.shared.id {
                let senderPayload = CurrentUser.shared.payload
                return Contact.save(senderPayload, context: context)
            }
            return Contact.save(.init(id: payload.senderID), context: context)
        }()
        if con.isGroup, !GroupInfo.hasSaved(for: payload.conID) {
            GroupInfo.save(.init(id: payload.conID), context: context)
        }
        return msg
    }
}


extension Msg {

    struct Payload: Codable {
        let id: String
        let content: MsgContent
        let date: Date
        let conID: String
        let senderID: String

        enum MsgContent: Codable {
            case Text(text: String)
            case Image
            case Video
            case Location
            case Emoji
            case Attachment
            case Voice

            var description: String {
                switch self {
                case .Text(let text):
                    return text
                default:
                    return "Unknown"
                }
            }

            var title: String {
                switch self {
                case .Text:
                    return "Text Message"
                default:
                    return "Unknown"
                }
            }
        }
    }
}
