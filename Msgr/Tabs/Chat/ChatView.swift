//
//  ChatView.swift
//  Msgr
//
//  Created by Aung Ko Min on 21/10/22.
//

import SwiftUI

struct ChatView: View {

    @EnvironmentObject private var tabManager: MainTabViewManager
    @StateObject private var viewModel: ChatViewModel

    init(_con: Con) {
        _viewModel = .init(wrappedValue: .init(_con: _con))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ChatTopBar()
            
            ChatScrollView {
                LazyVStack(alignment: .leading, spacing: viewModel.con.cellSpacing.cgFloat) {
                    Spacer(minLength: 5)
                        .id(1)
                    ForEach(viewModel.datasource.enuMsgs, id: \.element) { i, msg in
                        MsgCell(style: viewModel.msgStyle(for: msg, at: i, selectedId: viewModel.selectedId))
                            .environmentObject(msg)

                    }
                }
            }
            .overlay(ScrollDownButton(), alignment: .bottomTrailing)
            ChatInputBar()
        }
        .environmentObject(viewModel)
        .task {
            tabManager.tabBarVisibility = .hidden
        }
        .onDisappear {
            if !viewModel.con.hasMsgs && viewModel.con.lastMsg() != nil {
                viewModel.con.hasMsgs = true
            }
        }
        .navigationBarHidden(true)
    }
}
