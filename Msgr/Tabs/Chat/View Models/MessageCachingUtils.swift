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
    private var messageAuthors = [String: UserDisplayInfo]()
    private var messageAttachments = [String: Bool]()
    private var checkedMessageIds = Set<String>()
    private var quotedMessageMapping = [String: Msg]()
    
   @Published var scrollOffset: CGFloat = 0
    var scrollContentHeight: CGFloat = 0
    
    func authorId(for message: Msg) -> String {
        if let userDisplayInfo = userDisplayInfo(for: message) {
            return userDisplayInfo.id
        }
        
        let userDisplayInfo = saveUserDisplayInfo(for: message)
        return userDisplayInfo.id
    }
    
    func authorName(for message: Msg) -> String {
        if let userDisplayInfo = userDisplayInfo(for: message) {
            return userDisplayInfo.name
        }
        
        let userDisplayInfo = saveUserDisplayInfo(for: message)
        return userDisplayInfo.name
    }
    
    func authorImageURL(for message: Msg) -> URL? {
        if let userDisplayInfo = userDisplayInfo(for: message) {
            return userDisplayInfo.imageURL
        }
        
        let userDisplayInfo = saveUserDisplayInfo(for: message)
        return userDisplayInfo.imageURL
    }
    
    func authorInfo(from message: Msg) -> UserDisplayInfo {
        if let userDisplayInfo = userDisplayInfo(for: message) {
            return userDisplayInfo
        }
        
        let userDisplayInfo = saveUserDisplayInfo(for: message)
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
    
    func userDisplayInfo(with id: String) -> UserDisplayInfo? {
        for userInfo in messageAuthors.values {
            if userInfo.id == id {
                return userInfo
            }
        }
        return nil
    }
    
    func clearCache() {
        scrollOffset = 0
        messageAuthorMapping = [String: String]()
        messageAuthors = [String: UserDisplayInfo]()
        messageAttachments = [String: Bool]()
        checkedMessageIds = Set<String>()
        quotedMessageMapping = [String: Msg]()
    }
    
    // MARK: - private
    
    private func userDisplayInfo(for message: Msg) -> UserDisplayInfo? {
        if let userId = messageAuthorMapping[message.id.str],
           let userDisplayInfo = messageAuthors[userId] {
            return userDisplayInfo
        } else {
            return nil
        }
    }
    
    private func saveUserDisplayInfo(for message: Msg) -> UserDisplayInfo {
        guard let user = Contact.find(for: message.senderId.str) else {
            return .init(id: message.senderId.str, name: message.senderId.str, imageURL: nil)
        }
        let userDisplayInfo = UserDisplayInfo(
            id: user.id.str,
            name: user.name.str,
            imageURL: MockData.userProfilePhotoURL
        )
        messageAuthorMapping[message.id.str] = user.id
        messageAuthors[user.id.str] = userDisplayInfo
        return userDisplayInfo
    }
    
//    private func checkAttachments(for message: Msg) -> Bool {
//        let hasAttachments = !message.attachmentCounts.isEmpty
//        messageAttachments[message.id] = hasAttachments
//        return hasAttachments
//    }
}

/// Contains display information for the user.
public struct UserDisplayInfo {
    public let id: String
    public let name: String
    public let imageURL: URL?
    
    public init(id: String, name: String, imageURL: URL?) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
    }
}

extension Msg {
    
    var authorDisplayInfo: UserDisplayInfo {
        MessageCachingUtils.shared.authorInfo(from: self)
    }
    
    func userDisplayInfo(from id: String) -> UserDisplayInfo? {
        MessageCachingUtils.shared.userDisplayInfo(with: id)
    }
}
