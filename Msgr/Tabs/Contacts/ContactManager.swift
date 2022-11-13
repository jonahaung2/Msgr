//
//  ContactManager.swift
//  Conversation
//
//  Created by Aung Ko Min on 7/3/22.
//

import SwiftUI
import Contacts
import GlobalNotificationSwift

class ContactManager: ObservableObject {

    @Published var searchText = ""

    private var contacts = [Contact]()
    private var groups = [Con]()
    var displayContacts: [Contact] {
        if searchText.isEmpty {
            return contacts
        }else {
            return contacts.filter{ $0.name.str.lowercased().contains(searchText.lowercased()) }
        }
    }
    var displayGroups: [Con] {
        if searchText.isEmpty {
            return groups
        }else {
            return groups.filter{ $0.name.str.lowercased().contains(searchText.lowercased()) }
        }
    }

    init() {
        GlobalNotificationCenter.shared.addObserver(self, for: .init(GroupContainer.appGroupId+".contact.didSave")) {[weak self] notification in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.refresh()
            }
        }
        refresh()
    }

    func sync() {
        ContactsSyncOperations.startSync()
    }

    func deleteAll() {
        let context = CoreDataStack.shared.viewContext

        let request = Contact.fetchRequest()
        request.includesPropertyValues = false
        do {
            let objects = try context.fetch(request)
            for object in objects {
                context.delete(object)
            }
            CoreDataStack.shared.save()
            refresh()
        } catch {
            print(error)
        }
    }

    func refresh() {
        contacts = Contact.fecthAll()
        groups = Con.cons().filter{ $0.members_?.count ?? 0 > 2 }
        withAnimation {
            objectWillChange.send()
        }
    }
}
