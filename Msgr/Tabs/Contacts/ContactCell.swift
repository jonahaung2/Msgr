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
            ContactAvatarView(id: contact.id.str, urlString: contact.photoUrl.str, size: 25)
            Text(contact.name.str)
        }
        .background(
            Button(action: {
                if contact.id != CurrentUser.id {
                    ViewRouter.shared.routes.appendUnique(.chatView(conId: Con.fetchOrCreate(contact: contact).id.str))
                }
            }, label: {
                Color.clear
            })
        )
    }
}
