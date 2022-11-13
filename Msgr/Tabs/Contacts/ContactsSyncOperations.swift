//
//  ContactsSyncOperations.swift
//  Msgr
//
//  Created by Aung Ko Min on 7/11/22.
//

import Foundation
import CoreData
import Contacts
import PhoneNumberKit
import GlobalNotificationSwift

class ContactsSyncOperations {

    static func startSync() {
        let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = CoreDataStack.shared.viewContext

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.addOperations(ContactsSyncOperations.getOperationsToSyncContacts(context: backgroundContext), waitUntilFinished: false)
    }
    static func getOperationsToSyncContacts(context: NSManagedObjectContext) -> [Operation] {

        let fetchPhoneContacts = FetchPhoneContactsOperation()
        let phoneFormatters = FormatPhoneContactsOperation()

        let passPhoneContactsToFormatter = BlockOperation { [unowned fetchPhoneContacts, unowned phoneFormatters] in
            guard case let .success(phoneContacts)? = fetchPhoneContacts.result else {
                phoneFormatters.cancel()
                return
            }
            phoneFormatters.contacts = phoneContacts
        }

        passPhoneContactsToFormatter.addDependency(fetchPhoneContacts)
        phoneFormatters.addDependency(passPhoneContactsToFormatter)

        let fetchValidContacts = FetchValidContactsFromFirestore(context: context)

        let passFormattedToFetchServer = BlockOperation { [unowned phoneFormatters, unowned fetchValidContacts] in
            guard case let .success(formatted)? = phoneFormatters.result else {
                fetchValidContacts.cancel()
                return
            }
            fetchValidContacts.formatted = formatted
        }

        passFormattedToFetchServer.addDependency(phoneFormatters)
        fetchValidContacts.addDependency(passFormattedToFetchServer)
        return [fetchPhoneContacts, passPhoneContactsToFormatter, phoneFormatters, passFormattedToFetchServer, fetchValidContacts]
    }
}


class FetchPhoneContactsOperation: Operation {

    enum OperationError: Error {
        case cancelled
    }

    private let contactStore = CNContactStore()
    var result: Result<[CNContact], Error>?
    private var downloading = false
    override var isAsynchronous: Bool {
        return true
    }
    override var isExecuting: Bool {
        downloading
    }
    override var isFinished: Bool {
        result != nil
    }
    override func cancel() {
        super.cancel()
    }
    func finish(result: Result<[CNContact], Error>) {
        guard downloading else { return }

        willChangeValue(forKey: #keyPath(isExecuting))
        willChangeValue(forKey: #keyPath(isFinished))

        downloading = false
        self.result = result

        didChangeValue(forKey: #keyPath(isFinished))
        didChangeValue(forKey: #keyPath(isExecuting))
    }

    override func start() {
        willChangeValue(forKey: #keyPath(isExecuting))
        downloading = true
        didChangeValue(forKey: #keyPath(isExecuting))

        guard !isCancelled else {
            finish(result: .failure(OperationError.cancelled))
            return
        }
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactThumbnailImageDataKey] as [Any]

        var allContainers: [CNContainer] = []

        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            finish(result: .failure(error))
        }

        var results: [CNContact] = []

        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)

            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching containers")
            }
        }
        finish(result: .success(results))
    }
}


class FormatPhoneContactsOperation: Operation {

    enum OperationError: Error {
        case cancelled
    }

    private let phoneNumberKit = PhoneNumberKit()
    
    var result: Result<[String], Error>?
    private var isLoading = false
    var contacts: [CNContact]?

    override var isAsynchronous: Bool {
        return true
    }
    override var isExecuting: Bool {
        isLoading
    }
    override var isFinished: Bool {
        result != nil
    }
    override func cancel() {
        super.cancel()
    }
    func finish(result: Result<[String], Error>) {
        guard isLoading else { return }

        willChangeValue(forKey: #keyPath(isExecuting))
        willChangeValue(forKey: #keyPath(isFinished))

        isLoading = false
        self.result = result

        didChangeValue(forKey: #keyPath(isFinished))
        didChangeValue(forKey: #keyPath(isExecuting))
    }

    override func start() {
        willChangeValue(forKey: #keyPath(isExecuting))
        isLoading = true
        didChangeValue(forKey: #keyPath(isExecuting))

        guard !isCancelled, let contacts else {
            finish(result: .failure(OperationError.cancelled))
            return
        }

        
        var results = [String]()
        let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = CoreDataStack.shared.viewContext

        for contact in contacts {
            contact.phoneNumbers.forEach { phoneNumber in
                do {
                    let phoneNumber = try phoneNumberKit.parse(phoneNumber.value.stringValue, ignoreType: true)
                    let formatted = phoneNumberKit.format(phoneNumber, toType: .e164)
//                    let payload = Contact_(formatted, contact.givenName, formatted, "", pushToken: "")
//
//                    do {
//                        let request = Contact.fetchRequest(keyPath: "phoneNumber", equalTo: formatted)
//                        if let contact = (try backgroundContext.fetch(request)).first {
//                            contact.sync(with: payload)
//
//                        } else {
//                            let contact = Contact(context: backgroundContext)
//                            contact.sync(with: payload)
//                        }
//                    } catch {
//                        print(error)
//                    }
                    results.append(formatted)
                } catch {
                    print("Something went wrong")
                }
            }
        }
        NSManagedObjectContext.sync(context: backgroundContext)
        finish(result: .success(results))
    }
}


class FetchValidContactsFromFirestore: Operation {

    enum OperationError: Error {
        case cancelled
    }
    let queue = DispatchQueue(label: "FetchValidContactsFromFirestore")
    private let repo = UsersRepo()
    var result: Result<[Contact], Error>?
    var formatted: [String]?

    private var downloading = false
    override var isAsynchronous: Bool {
        return true
    }
    override var isExecuting: Bool {
        downloading
    }
    override var isFinished: Bool {
        result != nil
    }
    override func cancel() {
        super.cancel()
    }
    let context: NSManagedObjectContext
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    func finish(result: Result<[Contact], Error>) {
        guard downloading else { return }

        willChangeValue(forKey: #keyPath(isExecuting))
        willChangeValue(forKey: #keyPath(isFinished))

        downloading = false
        self.result = result
        if let count = try? result.get().count {
            GlobalNotificationCenter.shared.postNotification(.init(GroupContainer.appGroupId+".contact.didSave"))
            LocalNotifications.fireAlertMessage(title: "Success", body: "Synced \(count) contacts ..")
        }

        didChangeValue(forKey: #keyPath(isFinished))
        didChangeValue(forKey: #keyPath(isExecuting))
    }

    override func start() {
        willChangeValue(forKey: #keyPath(isExecuting))
        downloading = true
        didChangeValue(forKey: #keyPath(isExecuting))

        guard !isCancelled, let formatted else {
            finish(result: .failure(OperationError.cancelled))
            return
        }

        let group = DispatchGroup()
        var results = [Contact]()
        formatted.forEach { string in
            group.enter()
            repo.fetch([.phone(string)]) { result in
                switch result {
                case .success(let payload):
                    if let payload {
                        do {
                            let request = Contact.fetchRequest(keyPath: "id", equalTo: payload.id)
                            if let contact = (try self.context.fetch(request)).first {
                                contact.sync(with: payload)
                                results.append(contact)
                            } else {
                                let contact = Contact(context: self.context)
                                contact.sync(with: payload)
                                results.append(contact)
                            }
                        } catch {
                            print(error)
                        }
                    }
                case .failure(let error):
                    print(error)
                }
                group.leave()
            }
        }

        group.notify(queue: queue) {
            NSManagedObjectContext.sync(context: self.context)
            self.finish(result: .success(results))
        }
    }
}

extension Contact {
    func sync(with payload: Contact.Payload) {
        self.id = payload.id
        self.name = payload.name
        self.phoneNumber = payload.phone
        self.photoUrl = payload.photoURL
        self.pushToken = payload.pushToken
    }
}
