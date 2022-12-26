//
//  ContactManager.swift
//  Conversation
//
//  Created by Aung Ko Min on 7/3/22.
//

import SwiftUI
import Combine

class ContactsViewModel: NSObject, ObservableObject {

    private let contactsFetcher: CoreDataFetcher<Contact> = .init(sortDescriptor: ("name", true))
    private let groupInfosFetcher: CoreDataFetcher<GroupInfo> = .init(sortDescriptor: ("name", true))
    
    @Published var contacts = [Contact]()
    @Published var groupInfos = [GroupInfo]()

    private var cancellables = Set<AnyCancellable>()
    override init() {
        super.init()
        contactsFetcher
            .$items
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .sink { [weak self] items in
                guard let self = self else { return }
                self.contacts = items
            }.store(in: &cancellables)
        groupInfosFetcher
            .$items
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .sink { [weak self] items in
                guard let self = self else { return }
                self.groupInfos = items
            }.store(in: &cancellables)

        contacts = contactsFetcher.items
        groupInfos = groupInfosFetcher.items
    }
}

extension ContactsViewModel {
    func removeContact(at offsets: IndexSet) {
        Task { [weak self] in
            guard let self = self else { return }
            let objIds = offsets.compactMap{self.contacts[safe: $0]?.objectID}
            CoreDataStore.shared.deleteObjects(objIds)
        }

    }

    func deleteAll() {
        CoreDataStore.shared.deleteAllRecords(entity: "GroupInfo")
        CoreDataStore.shared.deleteAllRecords(entity: "Contact")
        CoreDataStore.shared.deleteAllRecords(entity: "Con")
        CoreDataStore.shared.deleteAllRecords(entity: "Msg")
    }
}
