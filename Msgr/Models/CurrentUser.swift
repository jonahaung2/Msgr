//
//  CurrentUserViewModel.swift
//  Msgr
//
//  Created by Aung Ko Min on 29/10/22.
//

import Foundation
import FirebaseAuth

struct CurrentUser {

    private static var user: User? { Auth.auth().currentUser }

    static var id: String {
        user?.uid ?? ""
    }
    static var name: String {
        user?.displayName ?? ""
    }
    static var phone: String {
        user?.phoneNumber ?? ""
    }

    static var photoURL: String {
        user?.photoURL?.absoluteString ?? MockData.userProfilePhotoURL.absoluteString
    }

    static var contact_: Contact_ {
        .init(id, name, phone, photoURL, pushToken: UserDefaultManager.shared.pushNotificationToken)
    }

}
