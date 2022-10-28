//
//  PushNotificationSender.swift
//  FirebaseStarterKit
//
//  Created by Florian Marcu on 1/28/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class PushNotificationSender {

    static let shared = PushNotificationSender()

    static let apnKey = "AAAACFxx6VY:APA91bHjtP9ccXft7qzpMhTE6Lso9YheenvG2z9kZ7XVfPJB0gOrAPOuEJE0iKuJNNJt8HSi8YBHA4sYwHjvqvNiEh1o0NvSN-lUzlDO4pwPWBXAbmPhqI6XI1wJRNZYtbJdYHEE2KUy"
    static let url = URL(string: "https://fcm.googleapis.com/fcm/send")!

    private let queue: OperationQueue = {
        $0.name = "MessageSender"
        $0.maxConcurrentOperationCount = 1
        $0.qualityOfService = .userInitiated
        return $0
    }(OperationQueue())


    private init() { }

    func sendPushNotification(to token: String, msg: Msg)  {
        queue.addOperation(PushNotiSendOperation(msg, token: token))
    }

    private func send(msg: Msg, token: String) {
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

        let request = NSMutableURLRequest(url: PushNotificationSender.url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(PushNotificationSender.apnKey)", forHTTPHeaderField: "Authorization")
        guard let body = try? JSONSerialization.data(withJSONObject: paramString, options: [.prettyPrinted]) else { return }
        request.httpBody = body
        URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
            if let error {
                print(error)
                return
            }
            if let data {
                print(data)
                msg.deliveryStatus = .Sent
            }
        }
        .resume()
    }
}
