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

    private let padding = 7.0

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .bold()
                        .imageScale(.large)
                        .padding(padding)
                }

                Spacer()

                VStack(spacing: 0) {
                    Text(viewModel.conversation.kind.title)
                        .font(.subheadline)
                        .bold()
                    Text(viewModel.conversation.typingText ?? viewModel.conversation.kind.subtitle)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .tapToRoute(.conInfo(viewModel.conversation.con.id))

                Spacer()

                Button {
                    simulateDemoMsg()
                } label: {
                    Image(systemName: "tuningfork")
                        .imageScale(.large)
                        .padding(padding)
                }
            }
            .padding(.horizontal, padding)
        }
        .background(.thickMaterial)
    }

    private func simulateDemoMsg() {
        let con = viewModel.conversation.con
        let contact = con.members.filter{ $0.id != CurrentUser.shared.id }.random()!
        let payload = Msg.Payload(id: UUID().uuidString, content: .Text(text: Lorem.random), date: .now, conID: con.id, senderID: contact.id)
        CoreDataStore.shared.save(msgPL: payload)
    }
}
