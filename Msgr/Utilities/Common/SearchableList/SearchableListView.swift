//
//  SearchableListView.swift
//  TL Device Monitor
//
//  Created by Aung Ko Min on 2/9/22.
//

import SwiftUI

struct SearchableListView<Content>: View where Content: View {

    private let header: Content
    @State private var showGroup: Bool = false
    @StateObject private var viewModel: SearchableListViewModel
    

    init(data: [ListCellData], showGroup: Bool = true, header: Content = EmptyView()) {
        self.header = header
        _viewModel = StateObject(wrappedValue: SearchableListViewModel(items: data))
        self.showGroup = showGroup
    }

    var body: some View {
        List {
            if viewModel.searchText.isWhitespace {
                header
                    .listRowSeparator(.hidden)
            }
            if showGroup {
                ForEach(String.alphabeta){ alpha in
                    let subItems = viewModel.items.filter{ $0.title.starts(with: alpha) }
                    if !subItems.isEmpty {
                        Section(alpha) {
                            ForEach(subItems) {
                                ListCell(data: $0)
                            }
                        }
                    }
                }
            } else {
                Section(viewModel.items.count.description) {
                    ForEach(viewModel.items) {
                        ListCell(data: $0)
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchText)
        .navigationBarItems(trailing: trailingItem)
    }
    private var trailingItem: some View {
        Toggle(isOn: $showGroup) {
            XIcon(.distribute_vertical_top)
        }
    }
}
