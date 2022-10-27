//
//  Msg.swift
//  Msgr
//
//  Created by Aung Ko Min on 22/10/22.
//

import Foundation

extension Msg {
    var msgType: MsgType {
        get { .init(rawValue: msgType_) ?? .Text }
        set { msgType_ = newValue.rawValue }
    }
    var recieptType: RecieptType {
        get { .init(rawValue: recieptType_) ?? .Send }
        set { recieptType_ = newValue.rawValue }
    }
    var deliveryStatus: DeliveryStatus {
        get { .init(rawValue: deliveryStatus_) ?? .Sent }
        set { deliveryStatus_ = newValue.rawValue }
    }
}

//extension Msg {
//    static func == (lhs: Msg, rhs: Msg) -> Bool {
//        lhs.id == rhs.id && lhs.deliveryStatus == rhs.deliveryStatus
//    }
//}
