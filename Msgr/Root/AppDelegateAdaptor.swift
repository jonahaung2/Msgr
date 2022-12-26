//
//  AppDelegateAdaptor.swift
//  Myanmar Song Book
//
//  Created by Aung Ko Min on 9/5/22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseMessaging
import BackgroundTasks

class AppDelegateAdaptor: NSObject, UIApplicationDelegate {

    let pushNotiReceiver = PushNotiHandler.shared
    let coreDataChanges = PersistanceChanges.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication .LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        Firestore.firestore().settings = settings
        
        pushNotiReceiver.startObserving()
        coreDataChanges.startObserving()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
        if Auth.auth().canHandleNotification(userInfo) {
            return .noData
        }
        Messaging.messaging().appDidReceiveMessage(userInfo)
        return .newData
    }

    func applicationWillTerminate(_ application: UIApplication) {
        scheduleAppRefresh()
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        if Auth.auth().canHandle(url) {
            return true
        }
        return false
    }

    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 0.5 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            Log(error)
        }
    }
}
