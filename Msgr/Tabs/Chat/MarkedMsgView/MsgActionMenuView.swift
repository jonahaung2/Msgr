//
//  MsgActionMenuView.swift
//  Msgr
//
//  Created by Aung Ko Min on 10/12/22.
//

import SwiftUI

enum MsgAction: String, Identifiable, CaseIterable {

    var id: String { rawValue }
    case Reply, Pin_to_Conversation, Forward, Copy_Message, Flag_Message, Mute_User, Edit_Message, Delete_Message

    var iconName: String {
        return "pin.fill"
    }

    static let defaultHeight = CGFloat(20)
}

struct MsgActionMenuView: View {

    let msg: Msg
    let style: MsgStyle
    @EnvironmentObject internal var chatViewModel: ChatViewModel

    var body: some View {
        VStack {
            ForEach(MsgAction.allCases) { action in
                VStack(alignment: .leading, spacing: 0) {
                    Button {
                        
                    } label: {
                        Label {
                            Text(action.rawValue)
                        } icon: {
                            Image(systemName: action.iconName)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(height: MsgAction.defaultHeight)
            }
        }
        .padding(.horizontal)
        .fixedSize()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 13))
    }
}
