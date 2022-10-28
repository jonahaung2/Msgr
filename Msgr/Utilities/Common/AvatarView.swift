//
//  AvatarView.swift
//  Conversation
//
//  Created by Aung Ko Min on 17/2/22.
//

import SwiftUI

struct AvatarView: View {

    let id: String

    var body: some View {
        Group {
            if let path = Media.path(userId: id), let image = UIImage(path: path) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .foregroundStyle(.secondary)
            }
        }
    }
}
