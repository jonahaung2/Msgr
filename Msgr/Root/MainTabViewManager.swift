//
//  MainTabViewManager.swift
//  Msgr
//
//  Created by Aung Ko Min on 21/10/22.
//

import SwiftUI

final class MainTabViewManager: ObservableObject {
    
    @Published var tabs = MainTab.allCases
    @Published var tabBarVisibility: Visibility = .visible
    @Published var current = MainTab.Inbox
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
