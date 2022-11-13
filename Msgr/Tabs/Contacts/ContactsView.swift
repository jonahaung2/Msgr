//
//  ContactsView.swift
//  Msgr
//
//  Created by Aung Ko Min on 21/10/22.
//

import SwiftUI

struct ContactsView: View {
    
    @StateObject private var manager = ContactManager()

    var body: some View {
        List {
            if manager.searchText.isWhitespace {
                Section {
                    Label("Create Contact", systemImage: XIcon.Icon.person_crop_circle.systemName)
                    Label("Create Group", systemImage: XIcon.Icon.plus_circle_fill.systemName)
                        .tapToPresent(CreateGroupContactPickerView())
                }
            }
            if !manager.displayGroups.isEmpty {
                Section {
                    ForEach(manager.displayGroups) { group in
                        Text(group.name.str)
                            .badge((group.members_?.count.description ?? "0") + " members")
                            .tapToPush(ChatView(_con: group))
                    }
                }
            }
            Section {
                ForEach(manager.displayContacts) { contact in
                    ContactCell(contact: contact)
                }
                .onDelete(perform: removeContact(at:))
            }
        }
        .navigationTitle("Contacts")
        .navigationBarItems(trailing: trailingItem)
        .searchable(text: $manager.searchText)
    }

    private func removeContact(at offsets: IndexSet) {
        for index in offsets {
            let item = manager.displayContacts[index]
            CoreDataStack.shared.viewContext.delete(item)
            CoreDataStack.shared.save()
            manager.refresh()
        }
    }

    private var trailingItem: some View {
        HStack {
            Button("Delete All") {
                manager.deleteAll()
            }
            Button("Sync Contacts") {
                manager.sync()
            }
            EditButton()
        }
    }
}
