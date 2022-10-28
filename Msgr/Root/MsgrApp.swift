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
    @StateObject var appState = AppState.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appDelegate.authenticator)
                .environment(\.managedObjectContext, appDelegate.persistance.context)

        }
    }
}

class AppState: ObservableObject {
    static let shared = AppState()
    @Published var userState: UserState = .launchAnimation
    private init() {}
}

enum UserState {
    case launchAnimation
    case loggedIn
}
