//
//  MsgCell.swift
//  Msgr
//
//  Created by Aung Ko Min on 22/10/22.
//

import SwiftUI

struct MsgCell: View {

    @EnvironmentObject internal var chatViewModel: ChatViewModel
    @EnvironmentObject internal var msg: Msg
    let style: MsgStyle

    var body: some View {
        VStack(spacing: 0) {
            if style.showTimeSeparater {
                TimeSeparaterCell(date: msg.date!)
            } else if style.showTopPadding {
                Spacer(minLength: 15)
            }

            HStack(alignment: .bottom, spacing: 2) {
                leftView()
                
                VStack(alignment: msg.recieptType.hAlignment, spacing: 2) {
                    if style.isSelected {
                        let text = msg.recieptType == .Send ? MsgDateView.dateFormatter.string(from: msg.date!) : msg.senderId.str
                        HiddenLabelView(text: text, padding: .top)
                    }

                    bubbleView()
                        .modifier(DraggableModifier(direction: msg.recieptType == .Send ? .left : .right))

                    if style.isSelected {
                        HiddenLabelView(text: msg.deliveryStatus.description, padding: .bottom)
                    }
                }
                rightView()
            }
        }
        .flippedUpsideDown()
        .transition(.move(edge: .top))
    }

    fileprivate func leftView() -> some View {
        Group {
            if msg.recieptType == .Send {
                Spacer(minLength: ChatKit.cellAlignmentSpacing)
            } else {
                VStack {
                    if style.showAvatar {
                        let userInfo = chatViewModel.cache.authorInfo(from: msg)
                        if let first = userInfo.name.first, let initial = String(first) {
                            Image(systemName: initial.lowercased() + ".circle.fill")
                                .font(.title2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .frame(width: ChatKit.cellLeftRightViewWidth)
            }
        }
    }

    fileprivate func rightView() -> some View {
        Group {
            if msg.recieptType == .Receive {
                Spacer(minLength: ChatKit.cellAlignmentSpacing)
            } else {
                VStack(alignment: .leading) {
                    CellProgressView(progress: msg.deliveryStatus)
                }
                .frame(width: ChatKit.cellMsgStatusSize)
            }
        }
    }

    internal func bubbleView() -> some View {
        Group {
            switch msg.msgType {
            case .Text:
                VStack(spacing: 0) {
                    TextBubble(text: msg.text.str)
                }
                .foregroundColor(style.textColor)
                .background(style.bubbleShape.fill(style.bubbleColor))
            case .Image:
                ImageBubble()
            case .Location:
                LocationBubble()
            case .Emoji:
                Text("Emoji")
                //                if let data = msg.emojiData {
                //                    EmojiBubble(data: data)
                //                }
            default:
                EmptyView()
            }
        }
        .gesture(
            TapGesture(count: 2)
                .onEnded {
                    HapticsEngine.shared.playTick()
                    withAnimation {
                        chatViewModel.selectedId = msg.id == chatViewModel.selectedId ? nil : msg.id
                    }
                }
        )
    }
}
