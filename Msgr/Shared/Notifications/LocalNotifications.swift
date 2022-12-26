//
//  LocalNotifications.swift
//  Msgr
//
//  Created by Aung Ko Min on 6/11/22.
//

import Foundation
import UIKit

class LocalNotifications {
    
    static func fireAlertMessage(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
        let request = UNNotificationRequest(identifier: "local_notification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error {
                Log(error)
            }
        }
    }
}
