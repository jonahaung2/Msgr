//
//  Conversation.swift
//  Msgr
//
//  Created by Aung Ko Min on 22/11/22.
//
import Foundation
import CoreData
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import Combine

class Conversation: ObservableObject {

    let con: Con
    @Published var kind: ConversationKind
    @Published var info: ConversationInfo = .init(typing: [])
    let cache: MessageCachingUtils

    var typingText: String? {
        let filtered = info.typing.filter{ $0 != CurrentUser.shared.id }
        guard !filtered.isEmpty else { return nil }
        if let id = filtered.last?.id {
            if let contact = cache.contactPayload(id: id) {
                return "\(contact.name) is Typing"
            }
        }
        return nil
    }

    private var cancellables = Set<AnyCancellable>()
    init(_ conID: String) {
        con = Con.fetchOrCreate(conId: conID, context: Persistance.shared.viewContext)
        cache = MessageCachingUtils()
        if con.isGroup, let groupInfo = cache.groupPayload(id: conID) {
            kind = .Group(groupInfo)
        } else if let id = con.oneToOneID, let contact = cache.contactPayload(id: id) {
            kind = .OneToOne(contact)
        } else {
            kind = .Deleted
        }
    }

    deinit {
        Log("Deinit")
    }
}

extension Conversation {

    func setTyping(isTyping: Bool) {
        var info = self.info
        let prev_isTyping = info.typing.contains(CurrentUser.shared.id)
        guard isTyping != prev_isTyping else { return }
        if isTyping {
            info.typing.appendUnique(CurrentUser.shared.id)
        } else {
            info.typing.remove(CurrentUser.shared.id)
        }
        Firestore
            .firestore()
            .collection("rooms")
            .document(con.id)
            .setData(info.dictionary!, completion: nil)
    }
}

extension Conversation {

    func startObserving() {
        switch kind {
        case .Group(let x):
            observeGroup(x)
        case .OneToOne(let x):
            observeContact(x)
        case .Deleted:
            break
        }
        observeRoom()
    }

    private func observeRoom() {
        Firestore
            .firestore()
            .collection("rooms")
            .document(con.id)
            .snapshotPublisher(includeMetadataChanges: true)
            .filter{$0.exists}
            .tryCompactMap{ try $0.data(as: ConversationInfo.self) }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: {[weak self] info in
                guard let self else { return }
                self.info = info
            })
            .store(in: &cancellables)
    }

    private func observeGroup(_ groupInfo: GroupInfo.Payload) {
      Firestore
            .firestore()
            .collection("groups")
            .document(groupInfo.id)
            .snapshotPublisher(includeMetadataChanges: true)
            .filter{$0.exists}
            .tryMap{ try $0.data(as: GroupInfo.Payload.self) }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: {[weak self] payload in
                guard let self else { return }
                CoreDataStore.shared.save(groupInfo: payload)
                CoreDataStore.shared.update(contactIDs: payload.members)
                self.kind = .Group(payload)
                self.cache.update([payload])
            })
            .store(in: &cancellables)
    }

    private func observeContact(_ contact: Contact.Payload) {
        Firestore
            .firestore()
            .collection("users")
            .document(contact.id)
            .snapshotPublisher(includeMetadataChanges: true)
            .filter{$0.exists}
            .tryMap{ try $0.data(as: Contact.Payload.self) }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: {[weak self] payload in
                guard let self else { return }
                CoreDataStore.shared.save(contact: payload)
                self.kind = .OneToOne(payload)
                self.cache.update([payload])
            })
            .store(in: &cancellables)
    }
}

extension Conversation {
    func updateIncomingHasRead() throws {
        let context = Persistance.shared.newTaskContext()
        try context.performAndWait {
            let request = Con.incomingUnreadFetchRequest(for: self.con.id)
            let msgs = try context.fetch(request)
            msgs.forEach{ $0.deliveryStatus_ = Msg.DeliveryStatus.Read.rawValue }
            try context.save()
        }
    }
}
