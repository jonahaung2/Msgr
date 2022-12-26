
//  InboxView.swift
//  Msgr
//
//  Created by Aung Ko Min on 21/10/22.
//

import SwiftUI

struct InboxView: View {

    @StateObject private var viewModel = InboxViewModel()

    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                InBoxCell()
                    .environmentObject(item)
            }
            .onDelete(perform: viewModel.deleteItems(offsets:))
        }
        .animation(.default, value: viewModel.items)
        .listStyle(.inset)
        .navigationBarItems(trailing: trailingItems)
        .searchable(text: .constant(""))
        .refreshable {
            viewModel.objectWillChange.send()
        }
        .task {
            viewModel.onAppear()
        }
        .onDisappear(perform: viewModel.onDisappear)
    }

    private var trailingItems: some View {
        HStack {
            EditButton()
        }
    }
}
