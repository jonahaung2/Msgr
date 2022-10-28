//
//  AppDelegateAdaptor.swift
//  Myanmar Song Book
//
//  Created by Aung Ko Min on 9/5/22.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegateAdaptor: NSObject, UIApplicationDelegate {

    let pushNotificationManager = PushNotificationManager.shared
    let authenticator = Authenticator.shared
    let persistance = Persistence.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication .LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        pushNotificationManager.registerForPushNotifications()
        authenticator.listen()
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        persistance.save()
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
    }

    func application(_ application: UIApplication,
        didReceiveRemoteNotification notification: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      if Auth.auth().canHandleNotification(notification) {
        completionHandler(.noData)
        return
      }
        completionHandler(.newData)
    }

    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
      if Auth.auth().canHandle(url) {
        return true
      }
        return true
    }
}
