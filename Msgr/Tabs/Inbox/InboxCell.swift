//
//  InboxCell.swift
//  Msgr
//
//  Created by Aung Ko Min on 25/10/22.
//

import SwiftUI

struct InBoxCell: View {

    let con: Con

    var body: some View {
        Group {
            AvatarView(id: con.id.str)
                .frame(width: 45, height: 45)
            if let msg = con.lastMsg() {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(con.name.str)
                            .font(.headline)
                        +
                        Text(" \(Msg.count(for: con.id.str)) ")
                            .italic()
                            .font(.caption2)

                        Text(msg.date?.toStringWithRelativeTime() ?? "" + " ")
                            .font(.footnote)
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
        .tapToPush(ChatView(_con: con))
    }

    private func foregroundStyle(for msg: Msg) -> some ShapeStyle {
        if msg.recieptType == .Send {
            return .secondary
        }
        return (msg.deliveryStatus == .Read ? .secondary : .primary)
    }
}

