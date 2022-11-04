//
//  InboxCell.swift
//  Msgr
//
//  Created by Aung Ko Min on 25/10/22.
//

import SwiftUI

struct InBoxCell: View {

    @EnvironmentObject private var conViewModel: ConViewModel

    var body: some View {
        HStack {
            AvatarView(id: conViewModel.id)
                .frame(width: 50, height: 50)

//            if let msg = con.lastMsg() {
//                Text(msg.text.str)
//                .lineLimit(3)
//                .foregroundStyle(foregroundStyle(for: msg))
//            }
//            Group {
//                switch con.conType {
//                case .single(let contact):
//                    AvatarView(id: contact?.id ?? "")
//                case .group(_):
//                    AvatarView(id: con.id.str)
//                }
//            }
//            .frame(width: 50, height: 50)
//
            if let msg = conViewModel.lasMsg {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(conViewModel.name)
                            .font(.headline)
                        +
                        Text(" \(Msg.count(for: conViewModel.id)) ")
                            .italic()
                            .font(.caption2)

//                        Text(msg.date?.toStringWithRelativeTime() ?? "" + " ")
//                            .font(.footnote)
                    }

                    Group {
                        Text(msg.text.str)
                        +
                        Text(" ")
                        +
                        Text(msg.deliveryStatus.description)
                            .font(.caption)
                    }
                    .lineLimit(3)
                    .foregroundStyle(foregroundStyle(for: msg))
                }
            }
        }
        .tapToPush(ChatView(_con: conViewModel.con))
    }

    private func foregroundStyle(for msg: Msg) -> some ShapeStyle {
        if msg.recieptType == .Send {
            return .secondary
        }
        return (msg.deliveryStatus == .Read ? .secondary : .primary)
    }
}

