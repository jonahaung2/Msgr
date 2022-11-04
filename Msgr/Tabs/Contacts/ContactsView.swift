//
//  ContactsView.swift
//  Msgr
//
//  Created by Aung Ko Min on 21/10/22.
//

import SwiftUI
import CoreData

struct ContactsView: View {
    
    @StateObject private var manager = ContactManager()

    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Contact.name, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Contact>

    private var displayContacts: [Contact] {
        if searchText.isEmpty {
            return Array(items)
        }else {
            return items.filter{ $0.name.str.lowercased().contains(searchText.lowercased()) }
        }
    }

    @State private var searchText = ""


    var body: some View {
        List {
            ForEach(displayContacts) { contact in
                ContactCell(contact: contact)
            }
            .onDelete(perform: removeContact(at:))
        }
        .navigationTitle("Contacts")
        .navigationBarItems(trailing: trailingItem)
        .searchable(text: $searchText)
    }

    private func removeContact(at offsets: IndexSet) {
        for index in offsets {
            let item = items[index]
            PersistentContainer.shared.viewContext.delete(item)
        }
        PersistentContainer.shared.save()
    }

    private var trailingItem: some View {
        HStack {
            Button("Sync Contacts") {
                manager.loadContacts()
            }
            EditButton()
        }
    }
}
