//
//  Contact+.swift
//  Msgr
//
//  Created by Aung Ko Min on 28/10/22.
//

import Foundation

extension Contact {
    var isCurrentUser: Bool {
        id == CurrentUser.shared.user.id
    }
}
