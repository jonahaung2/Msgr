//
//  ChatView.swift
//  Msgr
//
//  Created by Aung Ko Min on 21/10/22.
//

import SwiftUI

struct ChatView: View {
    
    @StateObject private var viewModel: ChatViewModel

    init(_ conID: String) {
        _viewModel = .init(wrappedValue: .init(conID))
    }

    var body: some View {
        ZStack {
            background
            VStack(spacing: 0) {
                ChatTopBar()
                ZStack {
                    ChatScrollView {
                        VStack(spacing: 0) {
                            Spacer(minLength: 2).id(1)
                            LazyVStack(spacing: viewModel.conversation.con.cellSpacing.cgFloat) {
                                ForEach(viewModel.datasource.blocks.lazy, id: \.msg) {  prev, msg, next in
                                    let style = viewModel.msgStyle(prev: next, msg: msg, next: prev)
                                    MsgCell(style: style)
                                        .environmentObject(msg)
                                }
                            }
                            .animation(.easeOut(duration: 0.2), value: viewModel.datasource.allMsgsCount)
                            .animation(.interactiveSpring(), value: viewModel.selectedMsg)
                        }
                    }

                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ScrollDownButton()
                        }
                    }
                }
                ChatInputBar()
            }
            .coordinateSpace(name: "chatView")

            markedMsgOverlayView
        }
        .environmentObject(viewModel)
        .navigationBarHidden(true)
        .statusBarHidden(viewModel.markedMsgDisplayInfo != nil)
        .task {
            TabRouter.shared.tabBarVisibility = .hidden
            viewModel.task()
        }
        .onAppear {
            PushNotiHandler.shared.currentConId = viewModel.conversation.con.id
        }
        .onDisappear {
            PushNotiHandler.shared.currentConId = nil
        }
    }

    @ViewBuilder
    private var background: some View {
        viewModel.conversation.con.bgImage.image
            .edgesIgnoringSafeArea(.all)
    }

    @ViewBuilder
    private var markedMsgOverlayView: some View {
        if let msgDisplayInfo = viewModel.markedMsgDisplayInfo {
            Group {
                background
                    .opacity(0.7)
                    .transition(.opacity.animation(.easeOut(duration: 0.3)))
                    .onTapGesture {
                        viewModel.setMarkedMsg(nil)
                    }

                MarkedMsgOverlayView(msgDisplayInfo: msgDisplayInfo)
            }
        }
    }
}
