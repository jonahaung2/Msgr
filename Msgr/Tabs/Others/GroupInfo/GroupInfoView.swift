//
//  GroupInfoView.swift
//  Msgr
//
//  Created by Aung Ko Min on 26/12/22.
//

import SwiftUI

struct GroupInfoView: View {

    @StateObject private var viewModel: GroupInfoViewModel

    init(_ groupID: String) {
        _viewModel = .init(wrappedValue: .init(groupID))
    }
    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    GroupAvatarView(conId: viewModel.groupInfo.id, urlString: viewModel.groupInfo.photoUrl, photoSize: .original, imageViewSize: .extraLarge)
                    Spacer()
                }

            }
            Section {
                FormCell2 {
                    Text("Name")
                } right: {
                    TextField("Group Name", text: $viewModel.groupInfo.name)
                        .onSubmit(viewModel.saveChanges)
                }
                TextField("Photo URL", text: $viewModel.groupInfo.photoUrl)
                    .onSubmit(viewModel.saveChanges)

            }
            Section("Admins") {
                ForEach(viewModel.groupInfo.getAdmins()) { member in
                    ContactCell(contact: member)
                }
            }

            Section("Members") {
                ForEach(viewModel.groupInfo.getMembers()) { member in
                    ContactCell(contact: member)
                }
            }

            if let contact = Contact.object(for: viewModel.groupInfo.createdByID, Persistance.shared.viewContext) {
                Section("Creater") {
                    ContactCell(contact: contact)
                }
            }
            
        }.navigationBarTitle("Group Info", displayMode: .large)
    }
}
