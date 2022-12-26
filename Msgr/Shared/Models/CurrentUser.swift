//
//  CurrentUserViewModel.swift
//  Msgr
//
//  Created by Aung Ko Min on 29/10/22.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestoreCombineSwift
import Combine

class CurrentUser: ObservableObject {

    static let shared = CurrentUser()
    private init() { }

    @Published var payload: Contact.Payload = {
        if let user = Auth.auth().currentUser {
            return .init(id: user.uid, name: user.phoneNumber ?? "", phone: user.phoneNumber ?? "", photoURL: "", pushToken: GroupContainer.pushToken, lastSeen: nil)
        }
        return Contact.Payload.init(id: GroupContainer.currentUserId ?? "")
    }()

    var isDemo: Bool {
        payload.phone == "+6598765432"
    }

    var id: String {
        Auth.auth().currentUser?.uid ?? GroupContainer.currentUserId ?? payload.id
    }

    var pushToken: String? { payload.pushToken }

    private let usersRef = Firestore.firestore().collection("users")
    private var cancellables = Set<AnyCancellable>()

    func observe(user: User) {
        GroupContainer.currentUserId = user.uid

        usersRef.document(user.uid)
            .getDocument(as: Contact.Payload.self, completion: { [weak self] result in
                guard let self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(var payload):
                        payload.pushToken = GroupContainer.pushToken
                        payload.lastSeen = nil
                        CoreDataStore.shared.save(contact: payload)
                        self.payload = payload
                        Log(payload.dictionary!)
                    case .failure(let error):
                        Log(error)
                    }
                }
            })
    }

    func unObserve() {
        setActive(isActive: false)
    }
    func setActive(isActive: Bool) {
        guard let user = Auth.auth().currentUser else { return }
        let data: [AnyHashable: Any] = isActive ? ["lastSeen": NSNull()] : ["lastSeen": Date.now.convert(from: .current, to: .singapore)]
        usersRef.document(user.uid).updateData(data, completion: nil)
    }

    func update() {
        guard let user = Auth.auth().currentUser else { return }
        usersRef.document(user.uid).setData(payload.dictionary!, completion: nil)
    }
}
