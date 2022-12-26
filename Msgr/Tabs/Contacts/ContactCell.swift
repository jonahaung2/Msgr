//
//  ContactCell.swift
//  Conversation
//
//  Created by Aung Ko Min on 7/3/22.
//

import SwiftUI

struct ContactCell: View {
    
    let contact: Contact

    var body: some View {
        HStack {
            ContactAvatarView(contact, .thumbnil, .small)
            HStack {
                Text(contact.name)
                Spacer()
            }
            .disabled(contact.isCurrentUser)
            .tapToRoute(.chatView(contact.conId))
            if contact.isCurrentUser {
                Spacer()
                Text("You")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
