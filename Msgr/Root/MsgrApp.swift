//
//  MsgrApp.swift
//  Msgr
//
//  Created by Aung Ko Min on 12/10/22.
//

import SwiftUI

@main
struct MsgrApp: App {

    @UIApplicationDelegateAdaptor(AppDelegateAdaptor.self) private var appDelegate
    private let persistence = Persistence.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(Authenticator.shared)
                .environment(\.managedObjectContext, persistence.context)
        }
    }
}
