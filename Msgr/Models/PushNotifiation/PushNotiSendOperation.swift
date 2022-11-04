//
//  PushNotiSendOperation.swift
//  Msgr
//
//  Created by Aung Ko Min on 28/10/22.
//

import SwiftUI

final class PushNotiSendOperation: Operation {

    private let msg_: Msg_
    private let token: String

    static let apnKey = "AAAACFxx6VY:APA91bHjtP9ccXft7qzpMhTE6Lso9YheenvG2z9kZ7XVfPJB0gOrAPOuEJE0iKuJNNJt8HSi8YBHA4sYwHjvqvNiEh1o0NvSN-lUzlDO4pwPWBXAbmPhqI6XI1wJRNZYtbJdYHEE2KUy"
    static let url = URL(string: "https://fcm.googleapis.com/fcm/send")!

    init(_ msg_: Msg_, token: String) {
        self.msg_ = msg_
        self.token = token
    }

    override func main() {

        if isCancelled { return }

        let paramString: [String : Any] = [
            "to" : token,
            "notification" : [
                "title" : msg_.senderId,
                "body" : msg_.text
            ],
            "data" : ["msg": msg_.dictionary as Any]
        ]

        if isCancelled { return }

        let request = NSMutableURLRequest(url: PushNotiSendOperation.url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(PushNotiSendOperation.apnKey)", forHTTPHeaderField: "Authorization")
        guard let body = try? JSONSerialization.data(withJSONObject: paramString, options: .fragmentsAllowed) else { return
        }
        print(body)
        request.httpBody = body

        let req = request as URLRequest
        if isCancelled { return }
        Task {
            if self.isCancelled { return }
            do {
                let (data, response) = try await  URLSession.shared.data(for: req)
                print(String(data: data, encoding: .utf8))
            } catch {
                print(error)
            }
        }
    }
}
