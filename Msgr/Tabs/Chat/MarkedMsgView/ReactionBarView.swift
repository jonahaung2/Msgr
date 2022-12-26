//
//  ReactionBarView.swift
//  Msgr
//
//  Created by Aung Ko Min on 10/12/22.
//

import SwiftUI

enum MsgReaction: String, Identifiable, CaseIterable {

    var id: String { rawValue }
    case thumbsUp, thumbsDown, love, wut, lol

    var iconName: String {
        switch self {
        case .lol:
            return "reaction_lol"
        case .thumbsUp:
            return "reaction_thumbsup"
        case .love:
            return "reaction_love"
        case .thumbsDown:
            return "reaction_thumbsdown"
        case .wut:
            return "reaction_wut"
        }
    }

    static let reactionSize = CGFloat(40)
}

struct ReactionBarView: View {

    let style: MsgStyle
    @EnvironmentObject internal var chatViewModel: ChatViewModel
    @EnvironmentObject private var msg: Msg

    var body: some View {
        ReactionsHStack(isSender: style.isSender) {
            HStack(spacing: 0) {
                ForEach(MsgReaction.allCases) { reaction in
                    Button(action: {
                        HapticsEngine.shared.playTick()
                        chatViewModel.setMarkedMsg(nil)
                        if reaction == .thumbsDown {
                            CoreDataStore.shared.deleteObjects([msg.objectID])
                        }
                    }, label: {
                        Image(reaction.iconName.appending("_big"))
                            .resizable()
                            .scaledToFit()
                            .padding(5)
                    })
                    .frame(size: .init(size: MsgReaction.reactionSize))
                }
            }
            .foregroundStyle(chatViewModel.conversation.con.themeColor.color)
            .padding(.horizontal, 8)
            .background()
            .roundWithBorder(cornerRadius: MsgReaction.reactionSize/2)
        }
    }
}


struct ReactionsHStack<Content: View>: View {

    var isSender: Bool
    var content: () -> Content

    var body: some View {
        HStack {
            if !isSender {
                Spacer()
            }
            content()

            if isSender {
                Spacer()
            }
        }
    }
}
