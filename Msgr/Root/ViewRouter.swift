//
//  MainTabViewManager.swift
//  Msgr
//
//  Created by Aung Ko Min on 21/10/22.
//

import SwiftUI

final class ViewRouter: ObservableObject {
    static let shared = ViewRouter()
    @Published var tabBarVisibility: Visibility = .visible
    @Published var current = MainTab.Inbox
    @Published var routes = [Route]()
    private init() { }
}

extension ViewRouter {
    enum Route: Hashable {
        case chatView(conId: String)
    }
}
