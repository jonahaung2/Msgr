//
//  SendButton.swift
//  Msgr
//
//  Created by Aung Ko Min on 21/10/22.
//

import SwiftUI

struct SendButton: View {

    @EnvironmentObject private var viewModel: ChatViewModel
    @EnvironmentObject private var server: MockServer
    
    var body: some View {
        Button(action: action) {
            if viewModel.inputText.isWhitespace {
                Image(systemName: "hand.thumbsup.fill")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .padding(5)
                    .transition(.scale(scale: 0.1))
            } else {
                Image(systemName: "chevron.up.circle.fill")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .padding(5)
                    .transition(.scale(scale: 0.1))
            }

        }
    }

    private func action() {
        triggerHapticFeedback(style: .rigid)
        viewModel.sendMessage()
    }
}
