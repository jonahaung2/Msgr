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
    @AppStorage(UserDefaultManager.shared.SaveLastVisitedPage) private var saveLastVisitedPage = true
    @StateObject private var tabManager = MainTabViewManager()

    var body: some View {
        TabView(selection: $tabManager.current) {
            ForEach(tabManager.tabs) { tab in
                tab
                    .view()
                    .onAppear {
                        tabManager.tabBarVisibility = .visible
                    }
                    .embeddedInNavigationView()
                    .toolbar(tabManager.tabBarVisibility, for: .tabBar)
                    .tabItem {
                        Label(tab.name, systemImage: tab.icon.systemName)
                    }
                    .tag(tab)
            }

        }
        .authenticatable()
        .environmentObject(tabManager)
        .accentColor(tintColor.color)
        .colorScheme(isDarkMode ? .dark : .light)
        .xListStyle(type: listStyle)
        .task {
            if !saveLastVisitedPage {
                tabManager.current = .Inbox
            }
        }
    }
}

