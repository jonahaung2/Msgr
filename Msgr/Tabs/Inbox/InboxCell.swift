//
//  InboxCell.swift
//  Msgr
//
//  Created by Aung Ko Min on 25/10/22.
//

import SwiftUI

struct InBoxCell: View {

    @EnvironmentObject private var model: InboxCellViewModel

    var body: some View {
        HStack {

            GroupAvatarView(conId: model.conId, urlString: model.photoURL, photoSize: .thumbnil, imageViewSize: .medium)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(model.title)
                        .fontWeight(model.hasUnreadMsgs ? .bold : .semibold)

                    if model.hasUnreadMsgs {
                        Image(systemName: "\(model.unreadCount).circle.fill")
                            .imageScale(.large)
                            .foregroundColor(.accentColor)
                    }
                }

                Text(model.text)
                    .lineLimit(3)
                    .fontWeight(model.hasUnreadMsgs ? .semibold : .regular)


                HStack {
                    Text("\(Image(systemName: "person.fill")) \(model.senderName)")
                    Spacer()
                    Text("\(model.date.formatted(.relative(presentation: .named)))")
                        .fontDesign(.serif)
                }
                .font(.footnote)
            }
            .tapToRoute(.chatView(model.conId))
        }
        .transition(.opacity)
    }
}

