//
//  CurrentUser.swift
//  Msgr
//
//  Created by Aung Ko Min on 25/10/22.
//

import Foundation
class CurrentUser: ObservableObject {

    static let shared = CurrentUser()
    var phone = "+6588585229"
    var user: Contact {
        if let x = Contact.find(for: phone) {
            return x
        }
        return Contact(phoneNumber: phone, name: "Aung Ko Min")
    }

    var activeDate = Date()
}

