//
//  MsgrApp.swift
//  Msgr
//
//  Created by Aung Ko Min on 12/10/22.
//

import SwiftUI
import CoreData

@main
struct MsgrApp: App {

    @UIApplicationDelegateAdaptor(AppDelegateAdaptor.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    private let tabRouter = TabRouter.shared
    private let coreDataStack = Persistance.shared
    private let userDefaultManager = UserDefaultManager.shared


    var body: some Scene {
        WindowGroup("mMsgr") {
            MainTabView()
                .environment(\.managedObjectContext, coreDataStack.viewContext)
                .environmentObject(appDelegate.pushNotiReceiver)
                .environmentObject(userDefaultManager)
                .environmentObject(tabRouter)

        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                CurrentUser.shared.setActive(isActive: true)
            case .background:
                Log("background")
            case .inactive:
                CurrentUser.shared.setActive(isActive: false)
            @unknown default:
                print("Unknown state")
            }
        }
        .backgroundTask(.appRefresh("refresh")) {
            await handleAppRefresh()
        }
    }
}

// Background Task
extension MsgrApp {

    private func handleAppRefresh() async {
        MsgrApp.sync()
    }

    static func sync() {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        let context = Persistance.shared.newTaskContext()
        let contactOperations = ContactsSyncOperations.getOperationsToSyncContacts(context: context)
        contactOperations.last?.completionBlock = {
            do {
                try context.save()
            } catch {
                Log(error)
            }
        }
        queue.addOperations(contactOperations, waitUntilFinished: false)
    }
}
