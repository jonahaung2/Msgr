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
            if let path = Media.path(userId: contact.id.str), let image = UIImage(path: path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .clipShape(Circle())
            }
            
            if contact.isMsgUser {
                XIcon(.pin)
            }
            Text(contact.name.str)
                .badge(contact.phoneNumber.str)
        }
        .tapToPush(ChatView(_contact: contact))
    }
}
