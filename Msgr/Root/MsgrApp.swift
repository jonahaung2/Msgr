//
//  MsgrApp.swift
//  Msgr
//
//  Created by Aung Ko Min on 12/10/22.
//

import SwiftUI
import BackgroundTasks

@main
struct MsgrApp: App {

    @UIApplicationDelegateAdaptor(AppDelegateAdaptor.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup("mMsgr") {
            MainTabView()
                .environment(\.managedObjectContext, CoreDataStack.shared.viewContext)
                .environmentObject(appDelegate.authenticator)
                .environmentObject(appDelegate.pushNotificationManager)
                .environmentObject(UserDefaultManager.shared)
                .environmentObject(ViewRouter.shared)
                .task {
                    scheduleAppRefresh()
                }
        }
        .backgroundTask(.appRefresh("refresh")) {
            await handleAppRefresh()
        }
    }
}

extension MsgrApp {

    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 0.5 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
            print("refresh scheduled")
        } catch {
            print(error)
        }
    }

    func handleAppRefresh() async {

        ContactsSyncOperations.startSync()
    }
}
