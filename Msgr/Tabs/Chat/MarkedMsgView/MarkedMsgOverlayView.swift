//
//  MarkedMsgOverlayView.swift
//  Msgr
//
//  Created by Aung Ko Min on 10/12/22.
//

import SwiftUI

struct MarkedMsgOverlayView: View {

    let msgDisplayInfo: MsgDisplayInfo

    var body: some View {
        VStack(spacing: 2) {
            ReactionBarView(style: msgDisplayInfo.style)
            MsgBubbleView(style: msgDisplayInfo.style)
                .frame(size: msgDisplayInfo.frame.size)
            HStack {

            }
            .frame(height: 40)
        }
        .position(x: msgDisplayInfo.frame.midX, y: msgDisplayInfo.frame.midY)
        .environmentObject(msgDisplayInfo.msg)
    }
}
