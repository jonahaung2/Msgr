//
//  GroupInfoViewModel.swift
//  Msgr
//
//  Created by Aung Ko Min on 26/12/22.
//

import Foundation
import FirebaseFirestore

class GroupInfoViewModel: ObservableObject {

    var groupInfo: GroupInfo

    init(_ groupID: String) {
        groupInfo = GroupInfo.object(for: groupID, Persistance.shared.viewContext) ?? GroupInfo.save(.init(id: groupID), context: Persistance.shared.viewContext)
    }

    func saveChanges() {
        let reference = Firestore.firestore().collection("groups")
        FirestoreRepo.update(GroupInfo.Payload(groupInfo), to: reference) {[weak self] err in
            guard let self else { return }
            if let err {
                Log(err)
            }
            DispatchQueue.main.async {
                try? self.groupInfo.managedObjectContext?.save()
            }
        }
    }
}
