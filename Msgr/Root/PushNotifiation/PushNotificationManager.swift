//
//  PushNotificationManager.swift
//  FirebaseStarterKit
//
//  Created by Florian Marcu on 1/28/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UIKit
import UserNotifications

class PushNotificationManager: NSObject, ObservableObject {

    static let shared = PushNotificationManager()

    var currentConId: String?

    private override init() {
        super.init()
    }

    func registerForPushNotifications() {

        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { _, _ in })
        UIApplication.shared.registerForRemoteNotifications()

        updateFirestorePushTokenIfNeeded()
    }

    func handle(userInfo: [AnyHashable: Any]) {
        let dic = userInfo as AnyObject
        print(dic)
    }
}


extension PushNotificationManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        UserDefaultManager.shared.pushNotificationToken = fcmToken.str
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }

    private func updateFirestorePushTokenIfNeeded() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if let token = Messaging.messaging().fcmToken {
            let usersRef = Firestore.firestore().collection("users").document(uid)
            usersRef.setData(["fcmToken": token], merge: true)
            UserDefaultManager.shared.pushNotificationToken = token
        }
    }
}

extension PushNotificationManager: UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let dic = notification.request.content.userInfo as NSDictionary
        print(dic)
        return [[.sound, .badge, .banner, .list]]
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {

    }
}
