//
//  PushNotiSendOperation.swift
//  Msgr
//
//  Created by Aung Ko Min on 28/10/22.
//

import SwiftUI

final class PushNotiSendOperation: Operation {

    private let msg: Msg
    private let token: String

    init(_ msg: Msg, token: String) {
        self.msg = msg
        self.token = token
    }

    override func main() {

        if isCancelled { return }

        var msgPayload = [AnyHashable: Any]()
        msgPayload["conId"] = msg.conId.str
        msgPayload["text"] = msg.text.str
        msgPayload["date"] = msg.date?.timeIntervalSince1970 ?? 0
        msgPayload["id"] = msg.id.str
        msgPayload["mType"] = msg.msgType.rawValue

        if let contact = Contact.find(for: msg.senderId.str) {
            var senderPayload = [AnyHashable: Any]()
            senderPayload["id"] = contact.id.str
            senderPayload["name"] = contact.name.str
            senderPayload["photoUrl"] = contact.photoUrl.str
            senderPayload["phoneNumber"] = contact.phoneNumber.str
            msgPayload["sender"] = senderPayload
        }

        var payload = [AnyHashable: Any]()
        payload["msg"] = msgPayload

        let paramString: [String : Any] = [
            "to" : token,
            "notification" : [
                "title" : msg.senderId.str,
                "body" : msg.text.str
            ],
            "data" : payload
        ]

        if isCancelled { return }

        let request = NSMutableURLRequest(url: PushNotificationSender.url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(PushNotificationSender.apnKey)", forHTTPHeaderField: "Authorization")
        guard let body = try? JSONSerialization.data(withJSONObject: paramString, options: [.prettyPrinted]) else { return
        }
        request.httpBody = body

        let req = request as URLRequest
        if isCancelled { return }
        Task {
            if self.isCancelled { return }
            do {
                let (data, response) = try await  URLSession.shared.data(for: req)
                print(data, response)
                self.msg.deliveryStatus = .Sent
            } catch {
                print(error)
            }
        }
    }
}
