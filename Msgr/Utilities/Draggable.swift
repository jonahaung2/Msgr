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


    func body(content: Content) -> some View {
        let dragGesture = DragGesture(minimumDistance: 5, coordinateSpace: .local)
            .onChanged { value in
                let offset = direction.offset(for: value.translation)
                let distance = abs(offset.width)
                if distance < 200 {
                    self.draggedOffset = offset
                    if Int(distance) == 199 {
                        HapticsEngine.shared.playSuccess()
                    }
                }
            }
            .onEnded { value in
                if draggedOffset.width != 0 {
                    draggedOffset.width = 0
                    HapticsEngine.shared.playSuccess()
                }

            }
        content
            .offset(draggedOffset)
            .gesture(dragGesture)
    }
}
