//
//  PushNotificationManager.swift
//  FirebaseStarterKit
//
//  Created by Florian Marcu on 1/28/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UserNotifications

class PushNotificationManager: NSObject, ObservableObject {

    static let shared = PushNotificationManager()

    var currentConId: String?

    private override init() {
        super.init()
    }

    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { _, _ in })
        UIApplication.shared.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
    }
}


extension PushNotificationManager: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        UserDefaultManager.shared.pushNotificationToken = fcmToken
    }
}

extension PushNotificationManager: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {

        let dic = notification.request.content.userInfo as [AnyHashable: AnyObject]
        print(dic)
        if let msgString = dic["msg"] as? String {
            print(msgString)
            if let data = msgString.data(using: .utf8) {
                do {
                    if let msgDic = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        if let msg_ = Msg_(dic: msgDic) {
                            let msg = Msg(context: PersistentContainer.shared.viewContext, msg_: msg_)
                            self.showMsg(msg: msg)
                            return currentConId == msg.conId ? [.banner, .badge, .sound, .list] : [.banner, .badge, .sound, .list]
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }
        return [.banner, .badge, .sound, .list]
    }
    private func showMsg(msg: Msg) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .MsgNoti, object: MsgNoti(type: .New(msg: msg)))
        }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        print(response)
    }

}

enum MsgNotiType {
    case New(msg: Msg)
    case Typing(isTyping: Bool)
    case Update(id: String)
}

struct MsgNoti {
    let type: MsgNotiType
}
extension Notification.Name {
    static let MsgNoti = Notification.Name("Notification.Conversation.MsgDidReceive")
}
extension NotificationCenter.Publisher.Output {
    var msgNoti: MsgNoti? { self.object as? MsgNoti }
}
