//
//  ChatTopBar.swift
//  Msgr
//
//  Created by Aung Ko Min on 22/10/22.
//

import SwiftUI

struct ChatTopBar: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: ChatViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Button {
                    if !viewModel.con.hasMsgs && viewModel.con.lastMsg() != nil {
                        viewModel.con.hasMsgs = true
                    }
                    viewModel.con.objectWillChange.send()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .padding(.horizontal)
                        .padding(.bottom)

                }

                Spacer()

                VStack(spacing: 0) {
                    Text(viewModel.con.name.str)
                        .bold()
                        .foregroundColor(.primary)
                        .tapToPush(ConInfoView().environmentObject(viewModel))

                    Text("Online")
                        .font(.caption)
                        .lineLimit(1)
                }

                Spacer()
                Button {
                    viewModel.simulatePushNoti()
                } label: {
                    Image(systemName: "phone.fill")
                        .imageScale(.large)

                }
                Button {
                    viewModel.isTyping.toggle()
                } label: {
                    Image(systemName: "video.fill")
                        .imageScale(.large)

                }
                Button {
                    viewModel.simulateDemoMsg()
                } label: {
                    Image(systemName: "tuningfork")
                        .imageScale(.large)
                        .padding(.horizontal)
                }
            }
        }
    }
}

