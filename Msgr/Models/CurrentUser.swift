//
//  CurrentUserViewModel.swift
//  Msgr
//
//  Created by Aung Ko Min on 29/10/22.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseMessaging

struct CurrentUser {

    private static var user: User? { Auth.auth().currentUser }

    static var id: String {
        user?.uid ?? ""
    }
    static var name: String {
        user?.displayName ?? (isDemo ? "Jonah Aung Ko Min" : "Aung Ko Min")
    }
    static var phone: String {
        user?.phoneNumber ?? "+6598765432"
    }

    static var photoURL: String {
        user?.photoURL?.absoluteString ?? "https://media-exp1.licdn.com/dms/image/C5603AQEmuML1GXI9DQ/profile-displayphoto-shrink_800_800/0/1630504470059?e=1672272000&v=beta&t=lAsZRcQIW79CdEN3Fps8WTRGuotjMBN8c1PSttvOsWo"
    }

    static var pushToken: String? {
        GroupContainer.pushToken
    }
    static var contactPL: Contact.Payload {
        .init(id: id, name: name, phone: phone, photoURL: photoURL, pushToken: pushToken)
    }

    static func update() {
        UsersRepo.shared.update(contactPL)
    }

    static var isDemo: Bool {
        phone == "+6598765432"
    }
}
