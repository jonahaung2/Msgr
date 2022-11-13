//
//  InboxCell.swift
//  Msgr
//
//  Created by Aung Ko Min on 25/10/22.
//

import SwiftUI

struct InBoxCell: View {

    let inboxCellViewModel: InboxCellViewModel

    var body: some View {
        HStack {
            AvatarView(id: inboxCellViewModel.id)
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
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(inboxCellViewModel.con.nameX)
                        .font(.headline)
                    +
                    Text(" \(inboxCellViewModel.msgCount) ")
                        .italic()
                        .font(.caption2)
                    Text(inboxCellViewModel.lastMsg.date?.toStringWithRelativeTime() ?? "" + " ")
                        .font(.footnote)
                }

                Group {
                    Text(inboxCellViewModel.lastMsg.text.str)
                    +
                    Text(" ")
                    +
                    Text(inboxCellViewModel.lastMsg.deliveryStatus.description)
                        .font(.caption)
                }
                .lineLimit(3)
                .foregroundStyle(foregroundStyle(for: inboxCellViewModel.lastMsg))
            }
        }
        .background(
            Button(action: {
                ViewRouter.shared.routes.appendUnique(.chatView(conId: inboxCellViewModel.con.id.str))
            }, label: {
                Color.clear
            })
        )
        .transition(.opacity)
    }

    private func foregroundStyle(for msg: Msg) -> some ShapeStyle {
        if msg.recieptType == .Send {
            return .secondary
        }
        return (msg.deliveryStatus == .Read ? .secondary : .primary)
    }
}

