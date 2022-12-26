//
//  MsgBubbleView.swift
//  Msgr
//
//  Created by Aung Ko Min on 10/12/22.
//

import SwiftUI

struct MsgBubbleView: View {

    let style: MsgStyle
    @EnvironmentObject private var msg: Msg

    @ViewBuilder
    var body: some View {
        Group {
            switch msg.msgType {
            case .Text:
                TextBubble(text: msg.text.str)
                    .foregroundColor(style.textColor)
                    .background(style.bubbleColor)
            case .Image:
                ImageBubble()
            case .Location:
                LocationBubble()
            case .Emoji:
                Text("Emoji")
            default:
                Color.clear
            }
        }
        .clipShape(style.bubbleShape)
    }
}

