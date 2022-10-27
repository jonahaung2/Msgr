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
                GeometryReader { proxy in
                    let frame = proxy.frame(in: .named(scrollAreaId))
                    let offset = frame.minY
                    Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: offset)
                }
                content()
                    .padding(.horizontal, 5)
                    .background(
                        GeometryReader { proxy in
                            Color.clear.preference(key: HeightPreferenceKey.self, value: proxy.size.height)
                        }
                    )

            }
            .scrollContentBackground(.visible)
            .scrollDismissesKeyboard(.immediately)
            .background(viewModel.con.bgImage.image)
            .coordinateSpace(name: scrollAreaId)
            .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
                DispatchQueue.main.async {
                    let offsetValue = value ?? 0
                    viewModel.cache.scrollOffset = offsetValue
                    let topValue = viewModel.cache.scrollContentHeight + offsetValue
                    if topValue < 700 {
                        if viewModel.datasource.loadMoreIfNeeded() {
                            viewModel.objectWillChange.send()
                        }
                    }
                }
            }
            .onPreferenceChange(HeightPreferenceKey.self) { value in
                DispatchQueue.main.async {
                    let contentHeight = value ?? 0
                    viewModel.cache.scrollContentHeight = contentHeight
                }
            }
            .flippedUpsideDown()
            .onChange(of: viewModel.scrollItem) {
                if let newValue = $0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.viewModel.scrollItem = nil
                    }
                    scroller.scroll(to: newValue)
                }
            }
        }
    }
}
