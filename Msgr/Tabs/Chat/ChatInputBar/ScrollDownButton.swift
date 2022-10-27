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
        Group {
            if viewModel.showScrollToLatestButton {
                Button(action: didTapButton) {
                    Image(systemName: "chevron.down.circle.fill")
                        .resizable()
                        .frame(width: 33, height: 33)
                        .padding()
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func didTapButton() {
        viewModel.scrollToBottom(true)
    }
}


