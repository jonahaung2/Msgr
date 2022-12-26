//
//  ViewRouter.swift
//  Msgr
//
//  Created by Aung Ko Min on 13/12/22.
//

import SwiftUI

final class TabRouter: ObservableObject {
    
    static let shared = TabRouter()
    private init() { }

    // Nav
    private let navRouters: [NavigationRouter] = TabRouter.Tab.allCases.map{ $0.router }
    var currentNavRouter: NavigationRouter {
        if let router = navRouters.filter({ $0.tab == currentTab }).first {
            return router
        }
        fatalError()
    }
    func navRouter(for tab: TabRouter.Tab) -> NavigationRouter {
        if let router = navRouters.filter({ $0.tab == tab }).first {
            return router
        }
        fatalError()
    }

    // Tab
    @Published var tabBarVisibility: Visibility = .visible
    @Published var currentTab = TabRouter.Tab.Inbox
}


final class NavigationRouter: ObservableObject {

    let tab: TabRouter.Tab
    @Published var routes = [Route]()
    init(tab: TabRouter.Tab) {
        self.tab = tab
    }

    enum Route: Hashable {
        case chatView(_ conID: String)
        case contactInfo(_ contactID: String)
        case conInfo(_ conID: String)
        case groupInfo(_ groupID: String)
    }
}

extension TabRouter {

    enum Tab: String, Identifiable, CaseIterable {
        var id: String { rawValue }
        case Inbox, Contacts, Settings
        var name: String { rawValue }
        var icon: XIcon.Icon {
            switch self {
            case .Inbox:
                return .message_badge_filled_fill
            case .Contacts:
                return .person_fill
            case .Settings:
                return .tuningfork
            }
        }
        @ViewBuilder
        func view() -> some View {
            switch self {
            case .Inbox:
                InboxView()
            case .Contacts:
                ContactsView()
            case .Settings:
                SettingsView()
            }
        }
        var router: NavigationRouter { .init(tab: self) }
    }
}
