//
//  ChatDatasource.swift
//  Msgr
//
//  Created by Aung Ko Min on 27/10/22.
//

import SwiftUI

final class ChatDatasource: ObservableObject {

    @Published var msgs = [Msg]()
    var enuMsgs: Array<(offset: Int, element: Msg)> {
        Array(msgs.enumerated())
    }
    
    init(conId: String) {
        msgs = Msg.msgs(for: conId)
    }

    
    func insert(_ msg: Msg, at i: Int, animated: Bool) {
        DispatchQueue.main.async {
            if animated {
                withAnimation(.linear(duration: 0.2)) {
                    self.msgs.insert(msg, at: i)
                }
            } else {
                self.msgs.insert(msg, at: i)
            }
        }
    }
}
