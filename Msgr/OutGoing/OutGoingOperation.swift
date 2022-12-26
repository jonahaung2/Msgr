//
//  NotiSendOperation.swift
//  Msgr
//
//  Created by Aung Ko Min on 9/12/22.
//

import Foundation

class OutGoingOperation: Operation {

    enum OperationError: Error {
        case cancelled, serialization, noData
    }

    enum API {
        static let apnKey = "AAAACFxx6VY:APA91bHjtP9ccXft7qzpMhTE6Lso9YheenvG2z9kZ7XVfPJB0gOrAPOuEJE0iKuJNNJt8HSi8YBHA4sYwHjvqvNiEh1o0NvSN-lUzlDO4pwPWBXAbmPhqI6XI1wJRNZYtbJdYHEE2KUy"
        static let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
    }

    var result: Result<Bool, Error>?
    private var currentTask: URLSessionDataTask?
    private var downloading = false
    override var isAsynchronous: Bool { true }
    override var isExecuting: Bool { downloading }
    override var isFinished: Bool { result != nil }

    private let noti: AnyNoti
    private let pushNoti: AnyNoti.PushNoti
    private let token: String

    init(_ noti: AnyNoti, _ pushNoti: AnyNoti.PushNoti, token: String) {
        self.noti = noti
        self.pushNoti = pushNoti
        self.token = token
    }

    override func cancel() {
        super.cancel()
        currentTask?.cancel()
    }

    private func finish(result: Result<Bool, Error>) {
        guard downloading else { return }

        willChangeValue(forKey: #keyPath(isExecuting))
        willChangeValue(forKey: #keyPath(isFinished))

        self.result = result
        downloading = false
        currentTask = nil

        switch result {
        case .success(let success):
            Log(success)
        case .failure(let failure):
            Log(failure)
        }
        didChangeValue(forKey: #keyPath(isFinished))
        didChangeValue(forKey: #keyPath(isExecuting))
    }

    override func start() {
        willChangeValue(forKey: #keyPath(isExecuting))
        downloading = true
        didChangeValue(forKey: #keyPath(isExecuting))

        guard !isCancelled, !token.isEmpty else {
            finish(result: .failure(OperationError.cancelled))
            return
        }

        let paramString = [
            "to" : token,
            "notification" : pushNoti.notification,
            "data" : ["noti": noti.dictionary!]
        ] as [AnyHashable : Any]

        do {
            let body = try JSONSerialization.data(withJSONObject: paramString, options: .prettyPrinted)

            let request: URLRequest = {
                $0.httpMethod = "POST"
                $0.setValue("application/json", forHTTPHeaderField: "Content-Type")
                $0.setValue("key=\(API.apnKey)", forHTTPHeaderField: "Authorization")
                $0.httpBody = body
                return $0 as URLRequest
            }(NSMutableURLRequest(url: API.url))

            currentTask = URLSession.shared.dataTask(with: request) { data, _, error in
                guard !self.isCancelled else {
                    self.finish(result: .failure(OperationError.cancelled))
                    return
                }
                if let error {
                    self.finish(result: .failure(error))
                    return
                }
                guard let data else {
                    self.finish(result: .failure(OperationError.noData))
                    return
                }
                Log(data)
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
                    guard let json else {
                        self.finish(result: .failure(OperationError.serialization))
                        return
                    }
                    if let success = json.value(forKey: "success") as? Int {
                        let successful = success == 1
                        self.finish(result: .success(successful))
                    } else {
                        self.finish(result: .failure(OperationError.serialization))
                    }
                } catch {
                    self.finish(result: .failure(error))
                }
            }
            currentTask?.resume()
        } catch {
            finish(result: .failure(OperationError.serialization))
        }
    }
}


extension AnyNoti {
    struct PushNoti: Codable {
        let title: String
        let subtitle: String
        let body: String
        var mutable_content: Bool = true
        var content_available: Bool = true
        var badge: Int = 0

        var notification: [AnyHashable: Any] {
            var notification = [AnyHashable: Any]()
            notification["title"] = title
            notification["subtitle"] = subtitle
            notification["body"] = body
            notification["mutable_content"] = mutable_content
            notification["sound"] = "rckit_incoming.aiff"
            notification["content_available"] = content_available
            notification["badge"] = badge
            return notification
        }
    }
}


