//
//  ScrollDownButton.swift
//  Msgr
//
//  Created by Aung Ko Min on 21/10/22.
//

import SwiftUI

struct ScrollDownButton: View {
    
    @EnvironmentObject private var viewModel: ChatViewModel
    
    var body: some View {
        HStack(alignment: .bottom) {
            if viewModel.isTyping {
                TypingIndicatorView()
                    .padding()
            }
            Spacer()
            if viewModel.showScrollToLatestButton {
                Button(action: didTapButton) {
                    Image(systemName: "chevron.down.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color.sectionBackground)
                        .padding()
                }
                .transition(.scale(scale: 0.1))
            }
        }
    }
    private func didTapButton() {
        triggerHapticFeedback(style: .soft)
        viewModel.scrollToBottom(true)
    }
}


