//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import SwiftUI

enum AttachmentPickerState {
    case files
    case photos
    case camera
    case custom
}

struct AddedAsset: Identifiable, Equatable {

    static func == (lhs: AddedAsset, rhs: AddedAsset) -> Bool {
        return lhs.id == rhs.id && lhs.url == rhs.url && lhs.type == rhs.type
    }

    let url: URL
    let image: UIImage
    let id: String
    let type: AssetType
    var extraData: [AnyHashable: Any] = [:]
    
    init(image: UIImage, id: String, url: URL, type: AssetType, extraData: [String: Any] = [:]) {
        self.image = image
        self.id = id
        self.url = url
        self.type = type
        self.extraData = extraData
    }
}

enum AssetType: String {
    case image
    case video
}

