
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
                InBoxCell(inboxCellViewModel: item)
            }
            .onDelete(perform: deleteItems)
        }.onAppear {
            viewModel.refreshView()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        offsets.map { viewModel.items[$0].con }.forEach(CoreDataStack.shared.viewContext.delete)
        viewModel.refreshView()
    }
}
