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
            }
            if style.showTopPadding {
                Color.clear.frame(height: 15)
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
        .id(msg.id)
    }

    fileprivate func leftView() -> some View {
        Group {
            if msg.recieptType == .Send {
                Spacer(minLength: ChatKit.cellAlignmentSpacing)
            } else {
                VStack(alignment: .trailing) {
                    if style.showAvatar {
                        AvatarView(id: chatViewModel.con.id.str)
                            .padding(2)
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
//                .frame(width: ChatKit.cellLeftRightViewWidth)
            }
        }
    }

    internal func bubbleView() -> some View {
        Group {
            switch msg.msgType {
            case .Text:
                TextBubble(text: msg.text.str)
                    .foregroundColor( msg.recieptType == .Send ? ChatKit.textTextColorOutgoing : nil)
                    .background(style.bubbleShape!.fill(chatViewModel.con.bubbleColor(for: msg)))
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
        .onTapGesture {
            HapticsEngine.shared.playTick()
            withAnimation(.interactiveSpring()) {
                chatViewModel.selectedId = msg.id == chatViewModel.selectedId ? nil : msg.id
            }
        }
//        .contextMenu{ MsgContextMenu().environmentObject(msg) }
    }
}
