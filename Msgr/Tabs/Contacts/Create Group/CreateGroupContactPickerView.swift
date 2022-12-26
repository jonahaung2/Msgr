//
//  CreateGroupContactPickerView.swift
//  Msgr
//
//  Created by Aung Ko Min on 13/11/22.
//

import SwiftUI

struct CreateGroupContactPickerView: View {

    @Environment(\.dismiss) private var dismiss
    private var contacts = Contact.fecthAll()
    private var displayContacts: [Contact] {
        if searchText.isWhitespace {
            return contacts
        } else {
            return contacts.filter{ $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    @State private var pickedContacts = [Contact]()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List {
                if !pickedContacts.isEmpty {
                    Section {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(pickedContacts) { contact in
                                    ContactAvatarView(contact, .thumbnil, .medium)
                                        .transition(.scale)
                                }
                            }
                            .padding(.bottom)
                            .transition(.scale)
                        }
                    }
                }
                Section {
                    ForEach(displayContacts) { contact in
                        HStack {
                            ContactAvatarView(contact, .thumbnil, .medium)
                            Text(contact.name)
                            Spacer()

                            if pickedContacts.contains(where: { c in
                                c.id == contact.id
                            }) {
                                XIcon(.checkmark_circle_fill)
                                    .foregroundColor(.accentColor)
                            } else {
                                XIcon(.circle)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onTapGesture {
                            if pickedContacts.contains(where: { c in
                                c.id == contact.id
                            }) {
                                withAnimation {
                                    pickedContacts.remove(contact)
                                }
                            } else {
                                withAnimation {
                                    pickedContacts.append(contact)
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Create Group")
            .searchable(text: $searchText)
            .navigationBarItems(leading: CancelButton(dismiss: _dismiss, isProtected: true), trailing: nextButton)
        }
    }

    private var nextButton: some View {
        Text("Next")
            .tapToPush(CreateGroupSaveView(contacts: pickedContacts, dismiss: _dismiss))
            .disabled(pickedContacts.isEmpty)
    }
}
