//
//  AppDelegateAdaptor.swift
//  Myanmar Song Book
//
//  Created by Aung Ko Min on 9/5/22.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import BackgroundTasks

class AppDelegateAdaptor: NSObject, UIApplicationDelegate {

    let pushNotificationManager = PushNotificationManager.shared
    let authenticator = Authenticator.shared
    let persistance = PersistentContainer.shared
    let server = MockServer()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication .LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        pushNotificationManager.registerForPushNotifications()
        authenticator.observe()
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.aungkomin.Msgr.v3.msgFetch", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        return true
    }

    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.aungkomin.Msgr.v3.msgFetch")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 1 * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }


    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        let context = PersistentContainer.shared.newBackgroundContext()
        let operations = Operations.getOperationsToFetchLatestEntries(using: context, server: server)
        let lastOperation = operations.last!

        task.expirationHandler = {
            queue.cancelAllOperations()
        }

        lastOperation.completionBlock = {
            task.setTaskCompleted(success: !lastOperation.isCancelled)
        }
        print(operations)
        queue.addOperations(operations, waitUntilFinished: false)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        persistance.save()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
        } else {
            completionHandler(.newData)
        }
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        if Auth.auth().canHandle(url) {
            return true
        }
        return true
    }
    
}
