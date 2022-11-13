//
//  ChatView.swift
//  Msgr
//
//  Created by Aung Ko Min on 21/10/22.
//

import SwiftUI

struct ChatView: View {

    @EnvironmentObject private var viewRouter: ViewRouter
    @EnvironmentObject private var pushNotificationManager: PushNotificationManager
    @StateObject private var viewModel: ChatViewModel

    init(_con: Con) {
        _viewModel = .init(wrappedValue: .init(_con: _con))
    }

    init(_contact: Contact) {
        self.init(_con: _contact.con())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ChatTopBar()
            ChatScrollView {
                LazyVStack(spacing: viewModel.con.cellSpacing.cgFloat) {
                    ForEach(viewModel.datasource.enuMsgs.lazy, id: \.element) { i, msg in
                      LazyView(MsgCell(style: viewModel.msgStyle(for: msg, at: i, selectedId: viewModel.selectedId))
                        .environmentObject(msg))
                    }
                }
            }
            .overlay(ScrollDownButton(), alignment: .bottomTrailing)

            ChatInputBar()
        }
        .background(ChatBackground())
        .accentColor(viewModel.con.themeColor.color)
        .environmentObject(viewModel)
        .navigationBarHidden(true)
        .task {
            viewRouter.tabBarVisibility = .hidden
        }
        .onAppear {
            pushNotificationManager.currentConId = viewModel.con.id
        }
        .onDisappear {
            pushNotificationManager.currentConId = nil
        }
    }
}
