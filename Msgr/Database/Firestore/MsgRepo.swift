//
//  MsgRepo.swift
//  Msgr
//
//  Created by Aung Ko Min on 5/11/22.
//

import Foundation
import Firebase
import FirebaseFirestore

class MsgRepo {

    static let shared = MsgRepo()
    let reference = Firestore.firestore().collection("msgs")

//    func add(_ item: Msg_, completion: ((Error?) -> Void)? = nil) {
//        FirestoreRepo.add(item, to: reference, completion: completion)
//    }
//
//    func update(_ item: Msg_, completion: ((Error?) -> Void)? = nil) {
//        FirestoreRepo.update(item, to: reference, completion: completion)
//    }
//
    func remove(_ id: String) {
        reference.document(id).delete()
    }

//    func fetch(_ queryItems: [Msg.Payload.QueryFilter], limit: Int = 0) async -> [Msg.Payload] {
//        var query = reference as Query
//        queryItems.forEach {
//            query = query.whereField($0.key, isEqualTo: $0.value)
//        }
//        if limit > 0 {
//            query = query.limit(to: limit)
//        }
//        do {
//            let snapshot = try await query.getDocuments()
//            let documents = snapshot.documents.compactMap{ $0.data() as NSDictionary }
//
//            return documents.compactMap{ MsgPayload(dic: $0)}
//        } catch {
//            print(error)
//            return []
//        }
//    }
}


//extension MsgPayload {
//
//    enum QueryFilter: Hashable, Identifiable {
//        var id: MsgPayload.QueryFilter { self }
//        case id(String)
//        case recipientId(String)
//
//        var key: String {
//            switch self {
//            case .id:
//                return "id"
//            case .recipientId:
//                return "recipientId"
//            }
//        }
//
//        var value: String {
//            switch self {
//            case .id(let string):
//                return string
//            case .recipientId(let string):
//                return string
//            }
//        }
//    }
//}
