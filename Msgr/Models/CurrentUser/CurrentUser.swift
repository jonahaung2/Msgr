//
//  CurrentUser.swift
//  Msgr
//
//  Created by Aung Ko Min on 25/10/22.
//

import Foundation
class CurrentUser: ObservableObject {

    static let shared = CurrentUser()

    var user = Msg.Sender.init(id: "1", name: "Aung Ko Min", photoURL: "")

    var activeDate = Date()

}
