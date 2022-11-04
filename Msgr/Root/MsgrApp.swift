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
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, appDelegate.persistance.viewContext)
                .environmentObject(appDelegate.authenticator)
                .environmentObject(appDelegate.server)
                .environmentObject(appDelegate.pushNotificationManager)
                .onChange(of: scenePhase) { phase in
                    switch phase {
                    case .active:
                        print("active")
                    case .inactive:
                        print("inactive")
                    case .background:
                        print("background")
                    @unknown default:
                        fatalError()
                    }
                }
        }
    }
}
