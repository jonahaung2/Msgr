//
//  MsgSender.swift
//  Msgr
//
//  Created by Aung Ko Min on 29/10/22.
//

import Foundation

final class MsgSender {

    static let shard = MsgSender()
    private init() { }
    
    private let queue: OperationQueue = {
        $0.name = "com.jonahaung.Msgr.MessageSender"
        $0.maxConcurrentOperationCount = 1
        $0.qualityOfService = .userInteractive
        return $0
    }(OperationQueue())

    func send(msgPayload: Msg.Payload, contactPayload: Contact.Payload) {
        guard CurrentUser.isDemo else { return }
        let pushOp = PushNotiSendOperation(msgPayload, contact: contactPayload)
        queue.addOperation(pushOp)
    }
}
