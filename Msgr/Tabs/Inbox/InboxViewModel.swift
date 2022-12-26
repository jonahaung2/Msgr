//
//  InboxViewModel.swift
//  Msgr
//
//  Created by Aung Ko Min on 5/11/22.
//

import SwiftUI
import Combine

final class InboxViewModel: ObservableObject {

    var items = [InboxCellViewModel]()

    private let fetcher: CoreDataFetcher<Msg> = .init(predicate: ("lastCon", "!=", "NULL"), sortDescriptor: ("date", false))

    private var cancellables = Set<AnyCancellable>()
    private var isViewVisiable = true
    init() {
        fetcher.$items
            .removeDuplicates()
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .compactMap({ msgs in
                return msgs.compactMap{ InboxCellViewModel(msg: $0)}
            })
            .sink { [weak self] items in
                guard let self = self else { return }
                self.items = items
                if self.isViewVisiable {
                    self.objectWillChange.send()
                }
            }
            .store(in: &cancellables)
    }

    func deleteItems(offsets: IndexSet) {
        offsets.forEach { i in
            if let item = items[safe: i] {
                if let con = Con.object(for: item.conId, Persistance.shared.viewContext) {
                    CoreDataStore.shared.deleteObjects([con.objectID])
                }

            }
        }
    }

    func onAppear() {
        isViewVisiable = true
        objectWillChange.send()
    }
    func onDisappear() {
        isViewVisiable = false
    }
}
