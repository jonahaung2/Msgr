//
//  NotificationService.swift
//  MsgrNotificationService
//
//  Created by Aung Ko Min on 5/11/22.
//

import UserNotifications
import Firebase

enum NotificationServieError: Error {
    case NoMsgNoti, Other
}
class NotificationService: UNNotificationServiceExtension {

    private var contentHandler: ((UNNotificationContent) -> Void)?
    private var bestAttemptContent: UNMutableNotificationContent?

    override init() {
        super.init()
        FirebaseApp.configure()
    }


    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        self.contentHandler = contentHandler
        bestAttemptContent = request.content.mutableCopy() as? UNMutableNotificationContent
        guard let bestAttemptContent else { return }
        handel(userInfo: bestAttemptContent.userInfo) {
            contentHandler(bestAttemptContent)
        }
    }


    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    private func handel(userInfo: [AnyHashable: Any], _ completion: @escaping () -> Void) {
        guard let noti = AnyNoti.noti(from: userInfo) else {
            completion()
            return
        }
        switch noti.notiType {
        case .msg(let type):
            switch type {
            case .newMsg(let payload):
                handleMsg(payload, completion)
            case .reaction(let reaction):
                Log(reaction)
                completion()
            }
        case .conNoti(let type):
            switch type {
            case .typing(let by):
                Log(by)
                completion()
            }
        }
    }

    private func handleMsg(_ payload: Msg.Payload, _ completion: @escaping () -> Void) {
        if !Contact.hasSaved(for: payload.senderID) {
            Contact.fetchRemotePayload(id: payload.senderID) { senderPL in
                if let senderPL {
                    CoreDataStore.shared.save(contact: senderPL)
                }
                CoreDataStore.shared.save(msgPL: payload)
                completion()
            }
        } else {
            CoreDataStore.shared.save(msgPL: payload)
            completion()
        }
    }
}

extension NotificationService {

    private func downloadImageFrom(url: String, handler: @escaping (UNNotificationAttachment?) -> Void) {
        let task = URLSession.shared.downloadTask(with: URL(string: url)!) { downloadedUrl, response, error in
            guard let downloadedUrl = downloadedUrl else {
                handler(nil)
                return
            }
            var urlPath = URL(fileURLWithPath: NSTemporaryDirectory())

            let uniqueUrlEnding = ProcessInfo.processInfo.globallyUniqueString + ".jpg"
            urlPath = urlPath.appendingPathComponent(uniqueUrlEnding)
            try? FileManager.default.moveItem(at: downloadedUrl, to: urlPath)
            do {
                let attachment = try UNNotificationAttachment(identifier: "picture", url: urlPath, options: nil)
                handler(attachment)
            } catch {
                Log("attachment error")
                handler(nil)
            }
        }
        task.resume()
    }
}
