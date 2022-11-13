//
//  InboxViewModel.swift
//  Msgr
//
//  Created by Aung Ko Min on 5/11/22.
//

import SwiftUI
import Combine

final class InboxViewModel: ObservableObject {

    @Published var items = [InboxCellViewModel]()

    private var cancellables = Set<AnyCancellable>()
    init() {
        NotificationCenter
            .default
            .publisher(for: .MsgNoti)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.refreshView()
            }
            .store(in: &cancellables)
        
    }

    func refreshView() {
        let cons = Con.cons()
        var items = [InboxCellViewModel]()
        cons.forEach { con in
            if let lastMsg = con.lastMsg() {
                let item = InboxCellViewModel(con: con, lastMsg: lastMsg)
                items.append(item)
            }
        }
        let sorted = items.sorted{ $0.lastMsg.date ?? .now > $1.lastMsg.date ?? .now}
        if self.items != sorted {
            self.items = sorted
        }
    }
}
