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
                    .background(
                        GeometryReader {
                            Color.clear
                                .preference(key: FramePreferenceKey.self, value: $0.frame(in: .named(scrollAreaId)))
                        }
                    )
            }
            .coordinateSpace(name: scrollAreaId)
            .flippedUpsideDown()
            .scrollDismissesKeyboard(.immediately)
            .onPreferenceChange(FramePreferenceKey.self) { frame in
                if let frame {
                    DispatchQueue.main.async {
                        viewModel.didUpdateVisibleRect(frame)
                    }
                }
            }
            .onChange(of: viewModel.scrollItem) {
                scroller.scroll(to: $0)
            }
        }
    }
}
