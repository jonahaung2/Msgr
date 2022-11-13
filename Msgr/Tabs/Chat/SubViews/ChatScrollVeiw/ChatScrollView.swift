//
//  ChatScrollView.swift
//  Conversation
//
//  Created by Aung Ko Min on 31/1/22.
//

import SwiftUI

struct ChatScrollView<Content: View>: View {
    
    let content: () -> Content
    @EnvironmentObject private var viewModel: ChatViewModel
    private let scrollAreaId = "scrollArea"
    
    var body: some View {
        ScrollViewReader { scroller in
            ScrollView(.vertical) {
                content()
                    .id(1)
                    .background(
                        GeometryReader { proxy in
                            let frame = proxy.frame(in: .named(scrollAreaId))
                            Color.clear
                                .preference(key: FramePreferenceKey.self, value: frame)
                        }
                    )
            }
            .scrollContentBackground(.visible)
            .scrollDismissesKeyboard(.immediately)
            .coordinateSpace(name: scrollAreaId)
            .flippedUpsideDown()
            .onPreferenceChange(FramePreferenceKey.self) { frame in
                if let frame {
                    DispatchQueue.main.async {
                        viewModel.didUpdateVisibleRect(frame)
                    }
                }
            }
            .onChange(of: viewModel.scrollItem) { newValue in
                if let newValue {
                    defer {
                        self.viewModel.scrollItem = nil
                    }
                    scroller.scroll(to: newValue)
                }
            }

        }
    }
}
