//
//  ChatDatasource.swift
//  Msgr
//
//  Created by Aung Ko Min on 27/10/22.
//

import SwiftUI

final class ChatDatasource: ObservableObject {

    @Published var allMsgs = [Msg]()
    var msgs: ArraySlice<Msg> {
        allMsgs.prefix(pageSize*currentPage)
    }
    private let pageSize = 50
    private var currentPage = 1

    var enuMsgs: Array<(offset: Int, element: Msg)> {
        Array(msgs.enumerated())
    }

    init(conId: String) {
        allMsgs = Msg.msgs(for: conId)
    }

    
    func insert(_ msg: Msg, at i: Int, animated: Bool) {
        DispatchQueue.main.async {
            if animated {
                withAnimation(.linear(duration: 0.2)) {
                    self.allMsgs.insert(msg, at: i)
                }
            } else {
                self.allMsgs.insert(msg, at: i)
            }
        }
    }

    func loadMoreIfNeeded() -> Bool {
        guard currentPage*pageSize <= allMsgs.count else {
            return false
        }
        currentPage += 1
        return true
    }
}
