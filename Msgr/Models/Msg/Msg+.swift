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
        senderId == CurrentUser.id ? .Send : .Receive
    }
    var deliveryStatus: DeliveryStatus {
        get { .init(rawValue: deliveryStatus_) ?? .Sent }
        set { deliveryStatus_ = newValue.rawValue }
    }
}
