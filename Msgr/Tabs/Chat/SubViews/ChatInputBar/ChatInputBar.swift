//
//  ChatInputBar.swift
//  Msgr
//
//  Created by Aung Ko Min on 21/10/22.
//

import SwiftUI

struct ChatInputBar: View {

    @EnvironmentObject private var viewModel: ChatViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom) {
                PlusMenuButton()
                InputTextView()
                SendButton()
            }
            .padding(.vertical, 5)
            .padding(.horizontal)
        }
        .background()
    }
}
