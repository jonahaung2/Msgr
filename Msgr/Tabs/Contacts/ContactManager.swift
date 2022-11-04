//
//  ContactManager.swift
//  Conversation
//
//  Created by Aung Ko Min on 7/3/22.
//

import Contacts
import PhoneNumberKit

class ContactManager: ObservableObject {

    private let phoneNumberKit = PhoneNumberKit()

    func loadContacts() {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        let context = PersistentContainer.shared.viewContext
        let repo = UsersRepo.shared

        var ops = [ContactSyncOperation]()
        let contacts = ContactManager.getContacts()
        for contact in contacts {
            contact.phoneNumbers.forEach { phoneNumber in
                do {
                    let phoneNumber = try phoneNumberKit.parse(phoneNumber.value.stringValue, ignoreType: true)
                    let formatted = phoneNumberKit.format(phoneNumber, toType: .e164)

                    let name = contact.givenName + " " + contact.familyName
                    let avatarData = contact.thumbnailImageData
                    if let avatarData {
                        Media.save(userId: formatted, data: avatarData)
                    }
                    let contact_ = Contact_(formatted, name, formatted, Media.path(userId: formatted), pushToken: nil)
                    Contact.fetchOrCreate(contact_: contact_)

                    let op = ContactSyncOperation(phoneNumber: formatted, context: context, repo: repo)
                    ops.append(op)
                } catch {
                    print("Something went wrong")
                }
            }
        }
        queue.addOperations(ops, waitUntilFinished: false)
    }

    class func getContacts() -> [CNContact] {
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactThumbnailImageDataKey] as [Any]
        
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
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
        return results
    }
}

import CoreData
// Downloads entries created after the specified date.
class ContactSyncOperation: Operation {

    enum OperationError: Error {
        case cancelled
    }

    private let context: NSManagedObjectContext
    private let repo: UsersRepo
    private let phoneNumber: String

    var result: Result<Contact_?, Error>?

    private var downloading = false
    private var currentDownloadTask: DownloadTask?

    init(phoneNumber: String, context: NSManagedObjectContext, repo: UsersRepo) {
        self.phoneNumber = phoneNumber
        self.context = context
        self.repo = repo
    }

    override var isAsynchronous: Bool {
        return true
    }

    override var isExecuting: Bool {
        return downloading
    }

    override var isFinished: Bool {
        return result != nil
    }

    override func cancel() {
        super.cancel()
        if let currentDownloadTask = currentDownloadTask {
            currentDownloadTask.cancel()
        }
    }

    func finish(result: Result<Contact_?, Error>) {
        guard downloading else { return }
        if case .success(let success) = result {
            if let contact_ = success {
                do {
                    let request = Contact.fetchRequest(keyPath: "phoneNumber", equalTo: phoneNumber)
                    if let contact = (try context.fetch(request)).first {
                        contact.id = contact_.id
                        contact.name = contact_.name
                        contact.name = contact_.name
                        contact.photoUrl = contact_.photoURL
                        contact.pushToken = contact_.pushToken
                    } else {
                        let contact = Contact(context: context)
                        contact.id = contact_.id
                        contact.name = contact_.name
                        contact.phoneNumber = contact_.phone
                        contact.photoUrl = contact_.photoURL
                        contact.pushToken = contact_.pushToken
                    }
                } catch {
                    print(error)
                }
            }
        }

        willChangeValue(forKey: #keyPath(isExecuting))
        willChangeValue(forKey: #keyPath(isFinished))

        downloading = false
        self.result = result
        currentDownloadTask = nil

        didChangeValue(forKey: #keyPath(isFinished))
        didChangeValue(forKey: #keyPath(isExecuting))
        print(result)
    }

    override func start() {
        willChangeValue(forKey: #keyPath(isExecuting))
        downloading = true
        didChangeValue(forKey: #keyPath(isExecuting))

        guard !isCancelled else {
            finish(result: .failure(OperationError.cancelled))
            return
        }
        repo.fetch([.phone(phoneNumber)], completion: finish)
    }
}
