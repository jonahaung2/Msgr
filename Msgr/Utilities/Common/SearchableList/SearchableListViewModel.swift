//
//  SearchableListViewModel.swift
//  TL Device Monitor
//
//  Created by Aung Ko Min on 2/9/22.
//

import Foundation
import Combine

final class SearchableListViewModel: ObservableObject {

    private let allItems: [ListCellData]
    @Published var items: [ListCellData]
    @Published var searchText = ""

    private var subscription: Set<AnyCancellable> = []

    init(items: [ListCellData]) {
        self.allItems = items
        self.items = items
        $searchText
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.searchItems(text)
            }
            .store(in: &subscription)
    }

    private func searchItems(_ string: String) {
        if string.isWhitespace {
            items = allItems
        } else {
            items = allItems.filter{ $0.title.lowercased().contains(string.lowercased()) }
        }
    }
}
