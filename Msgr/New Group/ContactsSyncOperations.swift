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

enum OperationError: Error { case cancelled }

struct ContactsSyncOperations {

    static func startSync(queue: OperationQueue, context: NSManagedObjectContext) {
        queue.addOperations(getOperationsToSyncContacts(context: context), waitUntilFinished: false)
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

        let fetchValidContacts = ContactsUpdateOperation(context: context)

        let passFormattedToFetchServer = BlockOperation { [unowned phoneFormatters, unowned fetchValidContacts] in
            guard case let .success(formatted)? = phoneFormatters.result else {
                fetchValidContacts.cancel()
                return
            }
            fetchValidContacts.queryValues = formatted.map{ [Contact.Payload.QueryFilter.phone($0)] }
        }

        passFormattedToFetchServer.addDependency(phoneFormatters)
        fetchValidContacts.addDependency(passFormattedToFetchServer)
        return [fetchPhoneContacts, passPhoneContactsToFormatter, phoneFormatters, passFormattedToFetchServer, fetchValidContacts]
    }
}


class FetchPhoneContactsOperation: Operation {

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
                Log("Error fetching containers")
            }
        }

        finish(result: .success(results))
    }
}


class FormatPhoneContactsOperation: Operation {

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

        for contact in contacts {
            contact.phoneNumbers.forEach { phoneNumber in
                do {
                    let phoneNumber = try phoneNumberKit.parse(phoneNumber.value.stringValue, ignoreType: true)
                    let formatted = phoneNumberKit.format(phoneNumber, toType: .e164)
                    results.append(formatted)
                } catch {
                    Log("Something went wrong")
                }
            }
        }
        finish(result: .success(results))
    }
}


class ContactsUpdateOperation: Operation {

    private var downloading = false
    override var isAsynchronous: Bool { true }
    override var isExecuting: Bool { downloading }
    override var isFinished: Bool { result != nil }
    override func cancel() { super.cancel()}

    let queue = DispatchQueue(label: "FetchValidContactsFromFirestore")
    private let repo = UsersRepo()
    var result: Result<[Contact], Error>?
    var queryValues: [[Contact.Payload.QueryFilter]]?
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
        do {
            let contacts = try result.get()
            LocalNotifications.fireAlertMessage(title: "Success", body: "Synced \(contacts.count) contacts ..")
        } catch {
            Log(error)
        }

        didChangeValue(forKey: #keyPath(isFinished))
        didChangeValue(forKey: #keyPath(isExecuting))
    }

    override func start() {
        willChangeValue(forKey: #keyPath(isExecuting))
        downloading = true
        didChangeValue(forKey: #keyPath(isExecuting))

        guard !isCancelled, let queryValues else {
            finish(result: .failure(OperationError.cancelled))
            return
        }

        let group = DispatchGroup()
        var results = [Contact]()
        queryValues.forEach { queryFilter in
            group.enter()
            repo.fetch(queryFilter) { result in
                switch result {
                case .success(let payload):
                    if let payload {
                        let contact = Contact.save(payload, context: self.context)
                        results.append(contact)
                    }
                case .failure(let error):
                    Log(error)
                }
                group.leave()
            }
        }

        group.notify(queue: queue) {
            guard !self.isCancelled else {
                self.finish(result: .failure(OperationError.cancelled))
                return
            }
            self.finish(result: .success(results))
        }
    }
}
