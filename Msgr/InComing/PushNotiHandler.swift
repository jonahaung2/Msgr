//
//  PushNotificationManager.swift
//  FirebaseStarterKit
//
//  Created by Florian Marcu on 1/28/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit
import FirebaseMessaging
import UserNotifications

final class PushNotiHandler: NSObject, ObservableObject {

    static let shared = PushNotiHandler()
    var currentConId: String?

    func startObserving() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { _, _ in })
        UIApplication.shared.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
    }
}

extension PushNotiHandler: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        GroupContainer.pushToken = fcmToken
    }
}

extension PushNotiHandler: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        handel(userInfo, completionHandler)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let noti = AnyNoti.noti(from: userInfo),
           case .msg(type: .newMsg(let msg)) = noti.notiType {
            TabRouter
                .shared
                .currentNavRouter
                .routes
                .appendUnique(
                    .chatView(msg.conID)
                )
        }
        completionHandler()
    }

    private func handel(_ userInfo: [AnyHashable: Any], _ completion: (UNNotificationPresentationOptions) -> Void) {
        guard let noti = AnyNoti.noti(from: userInfo) else {
            completion([.badge, .banner, .list])
            return
        }
        
        switch noti.notiType {
        case .msg(let type):
            switch type {
            case .newMsg(let payload):
                completion(currentConId == payload.conID ? [.sound] : [.banner, .sound])
            case .reaction(let reaction):
                Log(reaction)
                completion([.banner])
            }
        case .conNoti(let type):
            switch type {
            case .typing(let by):
                Log(by)
            }
            completion([.banner])
        }
    }
}
