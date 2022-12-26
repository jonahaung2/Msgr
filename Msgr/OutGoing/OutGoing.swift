//
//  NotiSender.swift
//  Msgr
//
//  Created by Aung Ko Min on 9/12/22.
//

import Foundation

class OutGoing {

    static let shared = OutGoing()
    private init() {}

    private let queue: OperationQueue = {
        $0.name = "com.jonahaung.Msgr.OutGoing"
        $0.maxConcurrentOperationCount = 1
        return $0
    }(OperationQueue())

    func send(_ noti: AnyNoti, pushNoti: AnyNoti.PushNoti, tokens: [String]) {
        guard CurrentUser.shared.isDemo else {
            return
        }
        let operations = tokens.map{ OutGoingOperation(noti, pushNoti, token: $0) }
        queue.addOperations(operations, waitUntilFinished: false)
    }
}
