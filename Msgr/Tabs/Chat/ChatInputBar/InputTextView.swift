//
//  InputTextView.swift
//  Msgr
//
//  Created by Aung Ko Min on 21/10/22.
//

import SwiftUI

struct InputTextView: View {

    @EnvironmentObject private var viewModel: ChatViewModel
    
    var body: some View {
        TextField("Text..", text: $viewModel.inputText, axis: .vertical)
            .lineLimit(1...10)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .overlay (
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 20)
            )
    }
}
