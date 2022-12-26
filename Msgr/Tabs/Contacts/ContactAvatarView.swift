//
//  ContactAvatarView.swift
//  Msgr
//
//  Created by Aung Ko Min on 13/11/22.
//

import SwiftUI
import Combine
import Photos

struct ContactAvatarView: View {

    let id: String
    let urlString: String?
    let photoSize: LocalMedia.MediaKind.PhotoKind.PhotoSize
    let imageViewSize: ImageSize

    init(id: String, urlString: String?, _ photoSize: LocalMedia.MediaKind.PhotoKind.PhotoSize, _ imageViewSize: ImageSize) {
        self.id = id; self.urlString = urlString; self.photoSize = photoSize; self.imageViewSize = imageViewSize
    }
    init(_ _contact: Contact.Payload, _ photoSize: LocalMedia.MediaKind.PhotoKind.PhotoSize, _ imageViewSize: ImageSize) {
        self.init(id: _contact.id, urlString: _contact.photoURL, photoSize, imageViewSize)
    }
    init(_ contact: Contact, _ photoSize: LocalMedia.MediaKind.PhotoKind.PhotoSize, _ imageViewSize: ImageSize) {
        self.init(Contact.Payload(contact), photoSize, imageViewSize)
    }

    var body: some View {
        ImageView(.avatars(id: id), photoSize, urlString: urlString) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFill()
                .fontWeight(.thin)
                .foregroundStyle(.tertiary)
        }
        .frame(size: .init(size: imageViewSize.width))
        .clipShape(Circle())
        .tapToRoute(.contactInfo(id))
    }
}

struct GroupAvatarView: View {

    let conId: String
    let urlString: String?
    let photoSize: LocalMedia.MediaKind.PhotoKind.PhotoSize
    let imageViewSize: ImageSize

    var body: some View {
        ImageView(.avatars(id: conId), photoSize, urlString: urlString) {
            Image(systemName: "person.2.circle.fill")
                .resizable()
                .scaledToFill()
                .fontWeight(.thin)
                .foregroundStyle(.tertiary)
        }
        .frame(size: .init(size: imageViewSize.width))
        .clipShape(Circle())
        .tapToRoute(.groupInfo(conId))
    }
}
