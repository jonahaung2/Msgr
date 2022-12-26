//
//  MainTabView.swift
//  Msgr
//
//  Created by Aung Ko Min on 12/10/22.
//

import SwiftUI

struct MainTabView: View {
    
    @AppStorage(UserDefaultManager.shared.Tint_Color) private var tintColor = TintColor.blue
    @EnvironmentObject private var tabRouter: TabRouter

    var body: some View {
        TabView(selection: $tabRouter.currentTab) {
            ForEach(TabRouter.Tab.allCases) { tab in
                RoutableNavView(tab: tab)
                    .toolbar(tabRouter.tabBarVisibility, for: .tabBar)
                    .tabItem {
                        Label(tab.name, systemImage: tab.icon.systemName)
                    }
                    .environmentObject(tabRouter.navRouter(for: tab))
                    .tag(tab)
            }
        }
        .authenticatable()
        .environmentObject(Authenticator.shared)
        .accentColor(tintColor.color)
    }
}
