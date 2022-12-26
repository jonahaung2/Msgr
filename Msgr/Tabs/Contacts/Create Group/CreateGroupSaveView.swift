//
//  CreateGroupSaveView.swift
//  Msgr
//
//  Created by Aung Ko Min on 13/11/22.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct CreateGroupSaveView: View {
    let contacts: [Contact]
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    var body: some View {
        List {
            Section("Group Info") {
                TextField("Group Name", text: $name)
            }
            Section("Members") {
                ForEach(contacts) { contact in
                    HStack {
                        ContactAvatarView(contact, .thumbnil, .small)
                        Text(contact.name)
                    }
                }
            }
        }
        .navigationBarItems(leading: CancelButton(isProtected: true), trailing: saveButton)
    }

    private var saveButton: some View {
        Button {
            saveAndExti()
        } label: {
            Text("Save")
        }
        .disabled(name.isWhitespace)
    }

    private func saveAndExti() {
        let currentUserId = CurrentUser.shared.id

        var members = contacts.compactMap{ $0.id }
        members.appendUnique(currentUserId)

        let payload = GroupInfo.Payload(id: UUID().uuidString, name: name, photoUrl: "", created: Date.now.timeIntervalSince1970, createdBy: currentUserId, members: members, admins: [currentUserId])

        Task {
            do {
                try await Firestore.firestore().collection("groups").document(payload.id).setData(payload.dictionary!)
                CoreDataStore.shared.save(groupInfo: payload)
                await MainActor.run {
                    self.dismiss()
                }
            } catch {
                Log(error)
            }

        }

    }
}
