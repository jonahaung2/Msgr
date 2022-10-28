//
//  UserDefaultManager.swift
//  TL Device Monitor
//
//  Created by Aung Ko Min on 24/8/22.
//

import SwiftUI

final class UserDefaultManager: ObservableObject {

    static let shared = UserDefaultManager()
    private let userDefaults = UserDefaults.standard

    let Is_Dark_Mode = "isDarkMode"
    let Tint_Color = "tintColor"
    let Current_Tab = "currenttab"
    let Is_Logged_In = "isLoggedIn"
    let Mobile_App_OSType = "Mobile_App_OSType"
    let List_Style = "List Style"
    let AppType = "App Type"
    let UseFaceID = "Use FaceID"
    let SaveLastVisitedPage = "SaveLastVisitedPage"

    @AppStorage("pageSize") var isLoggedIn = false
    @AppStorage("pushToken") var pushNotificationToken = ""
    @AppStorage("authVerificationID") var authVerificationID: String?

}
