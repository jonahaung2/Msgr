//
//  ScrollDownButton.swift
//  Msgr
//
//  Created by Aung Ko Min on 21/10/22.
//

import SwiftUI

struct ScrollDownButton: View {
    
    @EnvironmentObject private var viewModel: ChatViewModel

    @ViewBuilder
    var body: some View {
        if viewModel.showScrollToLatestButton {
            Button(action: didTapButton) {
                Image(systemName: "chevron.down.circle.fill")
                    .resizable()
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.tint, .background)
                    .frame(width: 40, height: 40)
                    .padding()
            }
            .transition(.scale.animation(.interactiveSpring()))
        }
    }
    private func didTapButton() {
        viewModel.scrollToBottom(true)
    }
}


