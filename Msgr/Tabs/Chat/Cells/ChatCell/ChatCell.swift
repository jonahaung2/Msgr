//
//  MessageCell.swift
//  MyBike
//
//  Created by Aung Ko Min on 22/1/22.
//

import SwiftUI

struct ChatCell: View {

    @EnvironmentObject internal var chatViewModel: ChatViewModel
    @EnvironmentObject internal var msg: Msg
    @State var style: MsgStyle

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
        .id(msg.id)
    }

    fileprivate func leftView() -> some View {
        Group {
            if msg.recieptType == .Send {
                Spacer(minLength: ChatKit.cellAlignmentSpacing)
            } else {
                VStack {
                    if style.showAvatar {
                        AvatarView(id: chatViewModel.cache.authorId(for: msg))
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
                VStack {
                    if style.showAvatar {
                        AvatarView(id: chatViewModel.cache.authorId(for: msg))
                    }else {
                        CellProgressView(progress: msg.deliveryStatus)
                    }
                }
                .frame(width: ChatKit.cellLeftRightViewWidth)
            }
        }
    }
    
}
