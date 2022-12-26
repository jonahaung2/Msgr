//
//  MsgStyle.swift
//  Conversation
//
//  Created by Aung Ko Min on 3/3/22.
//

import SwiftUI

struct MsgStyle {
    let bubbleShape: BubbleShape
    let showAvatar: Bool
    let showTimeSeparater: Bool
    let showTopPadding: Bool
    let isSelected: Bool
    let bubbleColor: Color
    let textColor: Color?
    let isSender: Bool
    let reducted: Bool
}

struct MsgDisplayInfo {
    let msg: Msg
    let frame: CGRect
    let style: MsgStyle
}
