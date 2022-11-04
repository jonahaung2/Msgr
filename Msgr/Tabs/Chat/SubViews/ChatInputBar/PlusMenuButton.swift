//
//  LeftMenuButton.swift
//  Conversation
//
//  Created by Aung Ko Min on 31/1/22.
//

import SwiftUI

struct PlusMenuButton: View {
    
    @EnvironmentObject private var viewModel: ChatViewModel
    
    var body: some View {
        Button {
            triggerHapticFeedback(style: .rigid)
            viewModel.simulateHasRead()
        } label: {
            Image(systemName: "camera.macro")
                .resizable()
                .frame(width: 25, height: 25)
                .padding(4)
        }
    }
}
