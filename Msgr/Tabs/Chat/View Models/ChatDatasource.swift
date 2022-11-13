//
//  ChatDatasource.swift
//  Msgr
//
//  Created by Aung Ko Min on 27/10/22.
//

import SwiftUI

final class ChatDatasource: NSObject, ObservableObject {

    private let pageSize = 50
    private var currentPage = 1
    private let conId: String

    @Published var allMsgs = [Msg]()

    var msgs: ArraySlice<Msg> {
        allMsgs.prefix(pageSize*currentPage)
    }

    var enuMsgs: Array<(offset: Int, element: Msg)> {
        Array(msgs.enumerated())
    }

    init(conId: String) {
        self.conId = conId
        allMsgs = Msg.msgs(for: conId)
    }
    
    func loadMoreIfNeeded() -> Bool {
        guard currentPage*pageSize <= allMsgs.count else {
            return false
        }
        currentPage += 1
        return true
    }

    func update() {
        allMsgs = Msg.msgs(for: conId)
    }
}
