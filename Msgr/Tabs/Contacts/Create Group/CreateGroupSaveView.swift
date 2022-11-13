//
//  CreateGroupSaveView.swift
//  Msgr
//
//  Created by Aung Ko Min on 13/11/22.
//

import SwiftUI

struct CreateGroupSaveView: View {
    let contacts: [Contact]
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    var body: some View {
        List {
            Section("Group Info") {
                TextField("Group Name", text: $name)
            }
            Section("Members") {
                ForEach(contacts) { contact in
                    HStack {
                        ContactAvatarView(id: contact.id.str, urlString: contact.photoUrl.str, size: 25)
                        Text(contact.name.str)
                    }
                }
            }
        }
        .navigationBarItems(trailing: saveButton)
    }

    private var saveButton: some View {
        Button {
            let con = Con(context: CoreDataStack.shared.viewContext)
            con.id = UUID().uuidString
            con.name = name
            con.date = Date()
            con.photoUrl = contacts.first?.photoUrl
            con.members_ = contacts.map{ $0.id.str }
            CoreDataStack.shared.save()
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text("Save")
        }.disabled(name.isWhitespace)

    }
}
