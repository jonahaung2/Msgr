//
//  Contact.Payload.swift
//  Msgr
//
//  Created by Aung Ko Min on 12/11/22.
//

import Foundation

extension Contact {
    struct Payload: Codable, Identifiable {
        let id: String
        let name: String
        let phone: String
        let photoURL: String?
        var pushToken: String?
    }
}

extension Contact.Payload {
    init(_ contact: Contact) {
        self.init(id: contact.id ?? "", name: contact.name ?? "", phone: contact.phoneNumber ?? "", photoURL: contact.photoUrl, pushToken: contact.pushToken)
    }
}
