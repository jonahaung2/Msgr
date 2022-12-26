//
//  MsgCell.swift
//  Msgr
//
//  Created by Aung Ko Min on 22/10/22.
//

import SwiftUI

struct MsgCell: View {

    @EnvironmentObject internal var chatViewModel: ChatViewModel
    @EnvironmentObject var msg: Msg
    let style: MsgStyle

    private var sender: Contact.Payload? {
        if let sender = msg.sender {
            return .init(sender)
        }
        return chatViewModel.conversation.cache.contactPayload(id: msg.senderId)
    }

    var body: some View {
        VStack(spacing: 0) {
            if style.showTimeSeparater  {
                TimeSeparaterCell(date: msg.date)
            } else if style.showTopPadding {
                Spacer(minLength: 15)
            }

            HStack(alignment: .bottom, spacing: 0) {
                leftView
                VStack(alignment: style.isSender ? .trailing : .leading, spacing: 2) {
                    if style.isSelected {
                        let text = style.isSender ? MsgDateView.dateFormatter.string(from: msg.date) : sender?.name ?? ""
                        HiddenLabelView(text: text, padding: .top)
                    }
                    InteractiveMsgBubbleView(style: style)
                    if style.isSelected {
                        HiddenLabelView(text: msg.deliveryStatus.description, padding: .bottom)
                    }
                }
                rightView
            }
        }
        .flippedUpsideDown()
        .transition(.asymmetric(insertion: .move(edge: .top), removal: .opacity))
    }

    @ViewBuilder
    private var leftView: some View {
        if style.isSender {
            Spacer(minLength: ChatKit.cellAlignmentSpacing)
        } else {
            VStack(alignment: .trailing) {
                if style.showAvatar, let sender  {
                    ContactAvatarView(sender, .thumbnil, .small)
                }
            }
            .frame(width: ImageSize.small.width + 5)
        }
    }
    @ViewBuilder
    private var rightView: some View {
        if !style.isSender {
            Spacer(minLength: ChatKit.cellAlignmentSpacing)
        } else {
            VStack {
                CellProgressView(progress: msg.deliveryStatus)
            }
            .frame(width: ChatKit.cellLeftRightViewWidth)
        }
    }
}
