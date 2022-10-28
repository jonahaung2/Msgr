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
                LazyVStack(spacing: viewModel.con.cellSpacing.cgFloat) {
                    Color.clear.frame(height: 1)
                        .id(1)
                    ForEach(viewModel.datasource.enuMsgs, id: \.element) { i, msg in
                        let style = viewModel.msgStyle(for: msg, at: i, selectedId: viewModel.selectedId)
                        LazyView(MsgCell(style: style)
                            .environmentObject(msg))
                    }
                }
            }
            .overlay(ScrollDownButton(), alignment: .bottomTrailing)
            
            ChatInputBar()
        }
        .accentColor(viewModel.con.themeColor.color)
        .environmentObject(viewModel)
        .task {
            tabManager.tabBarVisibility = .hidden
        }
        .navigationBarHidden(true)
    }
}
