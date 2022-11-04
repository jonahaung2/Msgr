//
//  MsgSender.swift
//  Msgr
//
//  Created by Aung Ko Min on 29/10/22.
//

import Foundation

class MsgSender {

    static let shard = MsgSender()
    private init() { }
    
    private let queue: OperationQueue = {
        $0.name = "MessageSender"
        $0.maxConcurrentOperationCount = 1
        $0.qualityOfService = .background
        return $0
    }(OperationQueue())

    func send(msg_: Msg_) {

        queue.addOperation {
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                Msg.msg(for: msg_.id)?.deliveryStatus = .Sent
//                let context = PersistentContainer.shared.newBackgroundContext()
//                let request = Msg.fetchRequest()
//                request.fetchLimit = 1
//                request.predicate = .init(format: "id == %@", msg_.id)
//                context.perform {
//                    do {
//                        let results = try context.fetch(request)
//                        if let msg = results.first {
//                            msg.deliveryStatus = .Sent
//                            try context.save()
//                        }
//                    } catch {
//                        print(error.localizedDescription)
//                    }
//                }
            }
        }
    }

    func sendIncoming(msg_: Msg_, token: String) {
        let pushOp = PushNotiSendOperation(msg_, token: token)
        pushOp.completionBlock = {
            print("success")
        }
        queue.addOperation(pushOp)
    }
}
