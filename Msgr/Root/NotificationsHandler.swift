//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//


import SwiftUI
import UIKit

/// Handles push notifications in the demo app.
/// When a notification is received, the channel id is extracted from the notification object.
/// The code below shows an example how to use it to navigate directly to the corresponding screen.
class NotificationsHandler: NSObject, ObservableObject, UNUserNotificationCenterDelegate {

    
    @Published var notificationChannelId: String?
    
    static let shared = NotificationsHandler()
    
    override private init() {}
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        defer {
            completionHandler()
        }

        guard let notificationInfo = try? PushNotiInfo(content: response.notification.request.content) else {
            return
        }

        guard let cid = notificationInfo.cid else {
            return
        }

        guard case UNNotificationDefaultActionIdentifier = response.actionIdentifier else {
            return
        }

    }
    
    func setupRemoteNotifications() {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
    }
    
}
