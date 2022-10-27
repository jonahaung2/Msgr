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
            .bold()
            .lineLimit(1...10)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background (
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(uiColor: .opaqueSeparator), lineWidth: 1)
            )
    }
}
