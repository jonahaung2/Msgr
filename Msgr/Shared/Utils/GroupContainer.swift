//
//  GroupContainer.swift
//  Msgr
//
//  Created by Aung Ko Min on 6/11/22.
//

import Foundation

final class GroupContainer: ObservableObject {

    static let appGroupId = "group.com.aungkomin.Msgr.v3"
    static let appIsExtension = Bundle.main.bundlePath.hasSuffix(".appex")
    static let container = UserDefaults(suiteName: appGroupId)!

    static var pushToken: String? {
        get {
            return container.string(forKey: "pushToken")
        }
        set {
            container.set(newValue, forKey: "pushToken")
        }
    }
    
    static var currentUserId: String? {
        get {
            return container.string(forKey: "currentUserId")
        }
        set {
            container.set(newValue, forKey: "currentUserId")
        }
    }

    static var lastHistoryTransactionTimestamp: Date? {
        get {
            container.object(forKey: "lastHistoryTransactionTimestamp") as? Date
        }

        set {
            container.set(newValue, forKey: "lastHistoryTransactionTimestamp")
        }
    }
}
