//
//  MainTabView.swift
//  Msgr
//
//  Created by Aung Ko Min on 12/10/22.
//

import SwiftUI

struct MainTabView: View {

    @AppStorage(UserDefaultManager.shared.Tint_Color) private var tintColor = TintColor.brown
    @AppStorage(UserDefaultManager.shared.Is_Dark_Mode) private var isDarkMode = false
    @AppStorage(UserDefaultManager.shared.List_Style) private var listStyle = XListStyle.Default
    @EnvironmentObject private var viewRouter: ViewRouter

    var body: some View {
        TabView(selection: $viewRouter.current) {
            ForEach(MainTab.allCases) { tab in
                NavigationStack(path: $viewRouter.routes) {
                    tab
                        .view()
                        .onAppear {
                            viewRouter.tabBarVisibility = .visible
                        }
                        .navigationDestination(for: ViewRouter.Route.self) { route in
                            switch route {
                            case .chatView(let conId):
                                if let con = Con.con(for: conId) {
                                    ChatView(_con: con)
                                }
                            }
                        }
                }
                .toolbar(viewRouter.tabBarVisibility, for: .tabBar)
                .tabItem {
                    Label(tab.name, systemImage: tab.icon.systemName)
                }
                .tag(tab)
            }
        }
        .authenticatable()
        .accentColor(tintColor.color)
        .colorScheme(isDarkMode ? .dark : .light)
        .xListStyle(type: listStyle)
    }
}

enum MainTab: String, Identifiable, CaseIterable {

    var id: String { rawValue }
    case Inbox, Contacts, Settings

    var name: String { rawValue }

    var icon: XIcon.Icon {
        switch self {
        case .Inbox:
            return .chart_line_uptrend_xyaxis
        case .Contacts:
            return .chart_bar_xaxis
        case .Settings:
            return .chart_bar_xaxis
        }
    }

    func view() -> some View {
        Group {
            switch self {
            case .Inbox:
                InboxView()
            case .Contacts:
                ContactsView()
            case .Settings:
                SettingsView()
            }
        }
        .navigationTitle(name)
    }
}
