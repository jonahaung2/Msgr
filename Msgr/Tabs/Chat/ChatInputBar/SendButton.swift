//
//  SendButton.swift
//  Msgr
//
//  Created by Aung Ko Min on 21/10/22.
//

import SwiftUI

struct SendButton: View {

    @EnvironmentObject private var viewModel: ChatViewModel

    var body: some View {
        Button(action: viewModel.sendMessage) {
            Image(systemName: viewModel.inputText.isWhitespace ?  "hand.thumbsup.fill" : "chevron.up.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .padding(.trailing, 4)
        }
    }
}
