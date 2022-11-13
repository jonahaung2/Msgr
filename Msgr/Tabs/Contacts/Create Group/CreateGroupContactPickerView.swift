//
//  CreateGroupContactPickerView.swift
//  Msgr
//
//  Created by Aung Ko Min on 13/11/22.
//

import SwiftUI

struct CreateGroupContactPickerView: View {

    @Environment(\.presentationMode) private var presentationMode
    private var contacts = Contact.fecthAll()
    private var displayContacts: [Contact] {
        if searchText.isWhitespace {
            return contacts
        } else {
            return contacts.filter{ $0.name.str.lowercased().contains(searchText.lowercased()) }
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
                                    ContactAvatarView(id: contact.id.str, urlString: contact.photoUrl.str, size: 50)
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
                            ContactAvatarView(id: contact.id.str, urlString: contact.photoUrl.str, size: 25)
                            Text(contact.name.str)
                            Spacer()
                            Button {
                                if pickedContacts.contains(where: { c in
                                    c.id == contact.id
                                }) {
                                    withAnimation {
                                        if let i = pickedContacts.firstIndex(of: contact) {
                                            pickedContacts.remove(at: i)
                                        }
                                    }
                                } else {
                                    withAnimation {
                                        pickedContacts.append(contact)
                                    }
                                }
                            } label: {
                                if pickedContacts.contains(where: { c in
                                    c.id == contact.id
                                }) {
                                    XIcon(.circle_fill)
                                } else {
                                    XIcon(.circle)
                                }
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
            .navigationBarTitle("Create Group")
            .searchable(text: $searchText)
            .navigationBarItems(trailing: nextButton)
        }
    }

    private var nextButton: some View {
        Text("Next")
            .tapToPush(CreateGroupSaveView(contacts: pickedContacts, presentationMode: _presentationMode))
            .disabled(pickedContacts.isEmpty)
    }
}
