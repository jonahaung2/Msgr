//
//  Media.swift
//  Conversation
//
//  Created by Aung Ko Min on 17/2/22.
//

import Foundation

class LocalMedia: NSObject {

    enum MediaKind {
        case photo(PhotoKind)
        case audio(conId: String, id: String)
        case video(conId: String, id: String)
        case location(conId: String, id: String)
        case attachment(conId: String, id: String)

        enum PhotoKind {
            case avatars(id: String)
            case msgs((conId: String, msgId: String))

            enum PhotoSize {
                case original
                case thumbnil

                var lastPath: String {
                    switch self {
                    case .original:
                        return "original.jpeg"
                    case .thumbnil:
                        return "thumbnail.jpeg"
                    }
                }
            }

            func path(for photoSize: LocalMedia.MediaKind.PhotoKind.PhotoSize) -> String {
                switch self {
                case .avatars(let id):
                    let components = ["photos", "avatars", id, photoSize.lastPath]
                    return Dir.document(components)
                case .msgs((let conId, let msgId)):
                    let components = ["photos", "messages", conId, msgId, photoSize.lastPath]
                    return Dir.document(components)
                }
            }
        }

        var path: String {
            switch self {
            case .photo(let kind):
                return kind.path(for: .original)
            case .audio(conId: let conId, id: let id):
                let components = ["audios", conId, "\(id).m4a"]
                return Dir.document(components)
            case .video(conId: let conId, id: let id):
                let components = ["videos", conId, "\(id).mp4"]
                return Dir.document(components)
            case .location(conId: let conId, id: let id):
                let components = ["locations", conId, "\(id).jpeg"]
                return Dir.document(components)
            case .attachment(conId: let conId, id: let id):
                let components = ["attachments", conId, "\(id).doc"]
                return Dir.document(components)
            }
        }
    }

    class func path(for kind: LocalMedia.MediaKind) -> String {
        kind.path
    }

    class func cleanUp(for kind: LocalMedia.MediaKind) {
        File.remove(kind.path)
    }

    class func save(_ data: Data, for kind: LocalMedia.MediaKind, encrypt: Bool) {
        let path = kind.path
        save(data, at: path, encrypt: encrypt)
    }
    class func save(_ data: Data, at path: String, encrypt: Bool) {
        if encrypt {
            if let encrypted = Cryptor.encrypt(data: data) {
                encrypted.write(path: path, options: .atomic)
            }
        } else {
            data.write(path: path, options: .atomic)
        }
        Log(File.created(path))
    }
}

extension LocalMedia {
    enum MediaKeep {
        static var Keep = MediaKeep.Day
        case Unknown, Month, Week, Day
    }

    class func cleanupExpired() {
        switch MediaKeep.Keep {
        case .Unknown:
            break
        case .Month:
            cleanupExpired(days: 7)
        case .Week:
            cleanupExpired(days: 30)
        case .Day:
            cleanupExpired(days: 1)
        }
    }

    class func cleanupExpired(days: Int) {
        var isDir: ObjCBool = false
        let extensions = ["jpeg", "jpg", "mp4", "m4a"]

        let past = Date().addingTimeInterval(TimeInterval(-days * 24 * 60 * 60))

        if let enumerator = FileManager.default.enumerator(atPath: Dir.document()) {
            while let file = enumerator.nextObject() as? String {
                let path = Dir.document([file])
                FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
                if isDir.boolValue == false {
                    let ext = (path as NSString).pathExtension
                    if extensions.contains(ext) {
                        let created = File.created(path)
                        if created.compare(past) == .orderedAscending {
                            File.remove(path)
                            Log(path)
                        }
                    }
                }
            }
        }

        if let files = try? FileManager.default.contentsOfDirectory(atPath: Dir.cache()) {
            for file in files {
                let path = Dir.cache(file)
                FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
                if isDir.boolValue == false {
                    let ext = (path as NSString).pathExtension
                    if (ext == "mp4") {
                        let created = File.created(path)
                        if (created.compare(past) == .orderedAscending) {
                            File.remove(path)
                        }
                    }
                }
            }
        }
    }

    class func cleanupManual(logout: Bool) {
        var isDir: ObjCBool = false
        let extensions = logout ? ["jpeg", "jpg", "mp4", "m4a", "manual", "loading"] : ["jpeg", "jpg", "mp4", "m4a"]

        if let enumerator = FileManager.default.enumerator(atPath: Dir.document()) {
            while let file = enumerator.nextObject() as? String {
                let path = Dir.document([file])
                FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
                if (isDir.boolValue == false) {
                    let ext = (path as NSString).pathExtension
                    if (extensions.contains(ext)) {
                        File.remove(path)
                    }
                }
            }
        }

        if let files = try? FileManager.default.contentsOfDirectory(atPath: Dir.cache()) {
            for file in files {
                let path = Dir.cache(file)
                FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
                if (isDir.boolValue == false) {
                    let ext = (path as NSString).pathExtension
                    if (ext == "mp4") {
                        File.remove(path)
                    }
                }
            }
        }
    }

    class func total() -> Int64 {
        var isDir: ObjCBool = false
        let extensions = ["jpeg", "jpg", "mp4", "m4a", "jpg"]

        var total: Int64 = 0

        if let enumerator = FileManager.default.enumerator(atPath: Dir.document()) {
            while let file = enumerator.nextObject() as? String {
                let path = Dir.document([file])
                FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
                if (isDir.boolValue == false) {
                    let ext = (path as NSString).pathExtension
                    if (extensions.contains(ext)) {
                        total += File.size(path)
                    }
                }
            }
        }

        if let files = try? FileManager.default.contentsOfDirectory(atPath: Dir.cache()) {
            for file in files {
                let path = Dir.cache(file)
                FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
                if (isDir.boolValue == false) {
                    let ext = (path as NSString).pathExtension
                    if (ext == "mp4") {
                        total += File.size(path)
                    }
                }
            }
        }

        return total
    }
}
