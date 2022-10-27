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
    @StateObject var appState = AppState.shared
    @StateObject var notificationsHandler = NotificationsHandler.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .overlay(launchScreenView())
                .environmentObject(Authenticator.shared)
                .environment(\.managedObjectContext, persistence.context)

        }
    }

    private func launchScreenView() -> some View {
        Group {
            if appState.userState == .launchAnimation {
                LaunchScreenView()
            }
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
