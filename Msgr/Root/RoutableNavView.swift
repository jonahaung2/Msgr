//
//  RoutableNavView.swift
//  Msgr
//
//  Created by Aung Ko Min on 11/12/22.
//

import SwiftUI

struct RoutableNavView: View {

    @EnvironmentObject private var tabRouter: TabRouter
    @EnvironmentObject private var viewRouter: NavigationRouter

    let tab: TabRouter.Tab

    var body: some View {
        NavigationStack(path: $viewRouter.routes) {
            tab.view()
                .navigationBarTitle(tab.name)
                .navigationDestination(for: NavigationRouter.Route.self) { route in
                    switch route {
                    case .chatView(let conID):
                        ChatView(conID)
                    case .contactInfo(let contactID):
                        ContactInfoView(contactID)
                    case .conInfo(let conID):
                        ConInfoView(conID)
                    case .groupInfo(let groupID):
                        GroupInfoView(groupID)
                    }
                }
                .task {
                    tabRouter.tabBarVisibility = .visible
                }
        }
    }
}
