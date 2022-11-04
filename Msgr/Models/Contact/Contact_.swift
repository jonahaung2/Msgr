//
//  Contact_.swift
//  Msgr
//
//  Created by Aung Ko Min on 29/10/22.
//

import Foundation

struct Contact_: Codable, Identifiable, Hashable {

    let id: String
    let name: String
    let phone: String
    let photoURL: String?
    var pushToken: String?

    init(_ id: String,_  name: String,_ phone: String,_ photoURL: String?, pushToken: String?) {
        self.id = id
        self.name = name
        self.phone = phone
        self.photoURL = photoURL.str
        self.pushToken = pushToken.str
    }

    init(_ contact: Contact) {
        self.init(contact.id.str, contact.name.str, contact.phoneNumber.str, contact.photoUrl, pushToken: contact.pushToken)
    }

}
