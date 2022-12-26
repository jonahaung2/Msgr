//
//  MsgSender.swift
//  Msgr
//
//  Created by Aung Ko Min on 25/12/22.
//

import Foundation

class MsgSender {

    static let shared = MsgSender()
    private init() { }

    private let queue: OperationQueue = {
        $0.name = "MsgSender"
        $0.maxConcurrentOperationCount = 1
        return $0
    }(OperationQueue())


    func send(_ content: Msg.Payload.MsgContent, con: Con) {

        let currentUser = CurrentUser.shared.payload
        let isGroup = con.isGroup
        let date = Date.now.convert(from: .current, to: .singapore)

        let payload = Msg.Payload(id: UUID().uuidString, content: content, date: date, conID: con.id, senderID: currentUser.id)

        let members = con.members

        let noti = AnyNoti(notiType: .msg(type: .newMsg(payload: payload)))
        let pushNoti = AnyNoti.PushNoti(title: currentUser.name, subtitle: isGroup ? con.title : currentUser.phone, body: payload.content.description)
        let tokens = members.filter { $0.id != currentUser.id }.compactMap{ $0.pushToken }

        guard tokens.isEmpty == false else { return }

        CoreDataStore.shared.save(msgPL: payload)
        OutGoing.shared.send(noti, pushNoti: pushNoti, tokens: tokens)

        queue.addOperation {
            if payload.senderID == CurrentUser.shared.id {
                Thread.sleep(forTimeInterval: Double.random(in: 1...3))
                Msg.object(for: payload.id, Persistance.shared.viewContext)?.deliveryStatus = .Seen
            }
        }
    }
}
