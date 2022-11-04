
//  InboxView.swift
//  Msgr
//
//  Created by Aung Ko Min on 21/10/22.
//

import SwiftUI
import CoreData

struct InboxView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Con.date, ascending: true)],
        predicate: .init(format: "hasMsgs == TRUE"),
        animation: .default)
    private var items: FetchedResults<Con>

    var body: some View {
        List {
            ForEach(items) {
                InBoxCell()
                    .environmentObject(ConViewModel(con: $0))
            }
            .onDelete(perform: deleteItems)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
