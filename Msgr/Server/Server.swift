//
//  Server.swift
//  Msgr
//
//  Created by Aung Ko Min on 29/10/22.
//

import Foundation

// A cancellable download task.
protocol DownloadTask {
    func cancel()
    var isCancelled: Bool { get }
}

struct Con_: Codable {
    let id: String
    let name: String
}

struct Msg_: Codable {

    let id: String
    let text: String
    let date: Double
    let conId: String
    let senderId: String
    let msgType: Int16

    init(id: String, text: String, date: Date, conId: String, senderId: String, msgType: Int16) {
        self.id = id
        self.text = text
        self.date = date.timeIntervalSince1970
        self.conId = conId
        self.senderId = senderId
        self.msgType = msgType
    }

    init(msg: Msg) {
        id = msg.id.str
        text = msg.text.str
        date = msg.date?.timeIntervalSince1970 ?? 0
        conId = msg.conId.str
        senderId = msg.senderId.str
        msgType = msg.msgType_
    }

    init?(dic: NSDictionary) {
        guard
            let id = dic["id"] as? String,
            let text = dic["text"] as? String,
            let conId = dic["conId"] as? String,
            let senderId = dic["senderId"] as? String,
            let msgType = dic["msgType"] as? Int
        else {
            return nil
        }
        self.init(id: id, text: text, date: Date(), conId: conId, senderId: senderId, msgType: Int16(msgType))
    }
}
