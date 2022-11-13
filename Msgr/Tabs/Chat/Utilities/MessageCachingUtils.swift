//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation
import UIKit
/// Caches messages related data to avoid accessing the database.
/// Cleared on chat channel view dismiss or memory warning.
class MessageCachingUtils: ObservableObject {
    
    static let shared = MessageCachingUtils()
    private init() { }
    
    private var messageAuthorMapping = [String: String]()
    private var messageAuthors = [String: Contact.Payload]()
    private var messageAttachments = [String: Bool]()
    private var checkedMessageIds = Set<String>()
    private var quotedMessageMapping = [String: Msg]()
    
    func authorId(for msg: Msg) -> String {
        if let userDisplayInfo = userDisplayInfo(for: msg) {
            return userDisplayInfo.id
        }
        
        let userDisplayInfo = saveUserDisplayInfo(for: msg)
        return userDisplayInfo.id
    }
    
    func authorName(for msg: Msg) -> String {
        if let userDisplayInfo = userDisplayInfo(for: msg) {
            return userDisplayInfo.name
        }
        
        let userDisplayInfo = saveUserDisplayInfo(for: msg)
        return userDisplayInfo.name
    }
    
    func authorImageURL(for msg: Msg) -> String? {
        if let userDisplayInfo = userDisplayInfo(for: msg) {
            return userDisplayInfo.photoURL
        }
        
        let userDisplayInfo = saveUserDisplayInfo(for: msg)
        return userDisplayInfo.photoURL
    }
    
    func authorInfo(from msg: Msg) -> Contact.Payload {
        if let userDisplayInfo = userDisplayInfo(for: msg) {
            return userDisplayInfo
        }
        
        let userDisplayInfo = saveUserDisplayInfo(for: msg)
        return userDisplayInfo
    }
    
    //    func quotedMessage(for message: Msg) -> Msg? {
    //        if checkedMessageIds.contains(message.id.str) {
    //            return nil
    //        }
    //
    //        if let quoted = quotedMessageMapping[message.id.str] {
    //            return quoted
    //        }
    //
    //        let quoted = message.quotedMessage
    //        if quoted == nil {
    //            checkedMessageIds.insert(message.id.str)
    //        } else {
    //            quotedMessageMapping[message.id.str] = quoted
    //        }
    //
    //        return quoted
    //    }
    
    func userDisplayInfo(with id: String) -> Contact.Payload? {
        for userInfo in messageAuthors.values {
            if userInfo.id == id {
                return userInfo
            }
        }
        return nil
    }
    
    func clearCache() {
        messageAuthorMapping = [String: String]()
        messageAuthors = [String: Contact.Payload]()
        messageAttachments = [String: Bool]()
        checkedMessageIds = Set<String>()
        quotedMessageMapping = [String: Msg]()
    }
    
    // MARK: - private
    
    private func userDisplayInfo(for msg: Msg) -> Contact.Payload? {
        if let userId = messageAuthorMapping[msg.id.str],
           let userDisplayInfo = messageAuthors[userId] {
            return userDisplayInfo
        } else {
            return nil
        }
    }
    
    private func saveUserDisplayInfo(for msg: Msg) -> Contact.Payload {
        
        guard let contact = Contact.find(for: msg.senderId.str) else {
            return .init(id: "", name: "", phone: "", photoURL: "", pushToken: "")
        }
        let contact_ = Contact.Payload(contact)
        
        messageAuthorMapping[msg.id.str] = contact_.id
        messageAuthors[contact_.id] = contact_
        return contact_
    }
    
    //    private func checkAttachments(for message: Msg) -> Bool {
    //        let hasAttachments = !message.attachmentCounts.isEmpty
    //        messageAttachments[message.id] = hasAttachments
    //        return hasAttachments
    //    }
}

/// Contains display information for the user.
//public struct UserDisplayInfo {
//
//    public let id: String
//    public let name: String
//    public let imageURL: URL?
//
//    public init(id: String, name: String, imageURL: URL?) {
//        self.id = id
//        self.name = name
//        self.imageURL = imageURL
//    }
//}

extension Msg {
    
    var authorDisplayInfo: Contact.Payload {
        MessageCachingUtils.shared.authorInfo(from: self)
    }
    
    func userDisplayInfo(from id: String) -> Contact.Payload? {
        MessageCachingUtils.shared.userDisplayInfo(with: id)
    }
}
