//
//  Draggable.swift
//  Conversation
//
//  Created by Aung Ko Min on 3/3/22.
//

import SwiftUI

struct DraggableModifier : ViewModifier {

    enum Direction {
        case left, right, top, bottom

        var isVertical: Bool { self == .top || self == .bottom }
        var isHorizontal: Bool { self == .left || self == .right }

        func offset(for draggableOffset: CGSize) -> CGSize {
            let width = self.isVertical ? 0 : (self == .left ? min(0, draggableOffset.width) : max(0, draggableOffset.width))
            let height = self.isHorizontal ? 0 : (self == .top ? max(0, draggableOffset.height) : min(0, draggableOffset.height))

            return .init(width: width, height: height)
        }
    }

    let direction: Direction

    @State private var draggedOffset: CGSize = .zero
    @State private var isDragging = false


    func body(content: Content) -> some View {
        let dragGesture = DragGesture()
            .onChanged { value in
                self.draggedOffset = direction.offset(for: value.translation)
            }
            .onEnded { _ in
                draggedOffset = .zero
                isDragging = false
                HapticsEngine.shared.playTick()
            }

        let pressGesture = LongPressGesture(minimumDuration: 0.1)
            .onEnded { ended in
                HapticsEngine.shared.playTick()
                draggedOffset = .zero
                isDragging = true
            }

        let combined = pressGesture.sequenced(before: dragGesture)

        content
            .offset(draggedOffset)
            .gesture(combined)
    }
}
