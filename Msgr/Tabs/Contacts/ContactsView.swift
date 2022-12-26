//
//  ContactsView.swift
//  Msgr
//
//  Created by Aung Ko Min on 21/10/22.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ContactsView: View {

//    @FirestoreQuery(
//        collectionPath: "groups",
//        predicates: [
//            .where("members", arrayContainsAny: [CurrentUser.shared.id])
//        ]
//    ) private var groups: [GroupInfo.Payload]

    @StateObject private var viewModel = ContactsViewModel()
    @EnvironmentObject private var viewRouter: NavigationRouter
    
    var body: some View {
        List {
            Section {
                Label("Create Group", systemImage: XIcon.Icon.person_2_circle.systemName)
                    .tapToPresent(CreateGroupContactPickerView())
            }

//            Section {
//                ForEach(groups) { group in
//                    Text(group.name)
//                        .xBadged(group.members.count.description + " members")
//                        .backgroundTapped {
//                            if !GroupInfo.hasSaved(for: group.id) {
//                                CoreDataStore.shared.save(groupInfo: group)
//                            }
//                            viewRouter.routes.appendUnique(.chatView(group.id))
//                        }
//                }
//                .onDelete { indexSet in
//                    let items = indexSet.compactMap{ groups[safe: $0] }
//                    items.forEach { each in
//                        FirestoreRepo.remove(each, to: Firestore.firestore().collection("groups"))
//                    }
//                }
//            }

            Section {
                ForEach(viewModel.groupInfos) { group in
                    Text(group.name)
                        .xBadged(group.members_.count.description + " members")
                        .xBadged(group.admins_.count.description)
                        .backgroundTapped {
                            viewRouter.routes.appendUnique(.chatView(group.id))
                        }
                }
                .onDelete { indexSet in
                    let ids = indexSet.compactMap{ viewModel.groupInfos[safe: $0]?.objectID }
                    CoreDataStore.shared.deleteObjects(ids)
                }
            }

            Section {
                ForEach(viewModel.contacts) {
                    ContactCell(contact: $0)
                        .disabled($0.isCurrentUser)
                }
                .onDelete(perform: viewModel.removeContact(at:))
            }
        }
        .navigationBarItems(trailing: trailingItem)
    }

    private var trailingItem: some View {
        HStack {
            Button("Delete All") {
                viewModel.deleteAll()
            }
            Button("Sync") {
                MsgrApp.sync()
            }
            EditButton()
        }
    }
}
