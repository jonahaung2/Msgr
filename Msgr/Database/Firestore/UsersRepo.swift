//
//  UsersRepo.swift
//  Msgr
//
//  Created by Aung Ko Min on 4/11/22.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class UsersRepo {

    static let shared = UsersRepo()
    let reference = Firestore.firestore().collection("users")

    func add(_ item: Contact.Payload, completion: ((Error?) -> Void)? = nil) {
        FirestoreRepo.add(item, to: reference, completion: completion)
    }

    func update(_ item: Contact.Payload, completion: ((Error?) -> Void)? = nil) {
        FirestoreRepo.update(item, to: reference, completion: completion)
    }

    func remove(_ item: Contact.Payload, completion: @escaping (Error?)-> Void) {
        FirestoreRepo.remove(item, to: reference, completion: completion)
    }

    func fetch(_ queryItems: [Contact.Payload.QueryFilter], limit: Int = 0) async -> [Contact.Payload] {
        var query = reference as Query
        queryItems.forEach {
            query = query.whereField($0.key, isEqualTo: $0.value)
        }
        if limit > 0 {
            query = query.limit(to: limit)
        }
        return await FirestoreRepo.fetch(query: query)
    }
    
    func fetch(_ queryItems: [Contact.Payload.QueryFilter], limit: Int = 0, completion: @escaping (Result<[Contact.Payload], Error>) -> Void) {
        var query = reference as Query
        queryItems.forEach {
            query = query.whereField($0.key, isEqualTo: $0.value)
        }
        if limit > 0 {
            query = query.limit(to: limit)
        }
        FirestoreRepo.fetch(query: query, completion: completion)
    }
    
    func fetch(_ queryItems: [Contact.Payload.QueryFilter], completion: @escaping (Result<Contact.Payload?, Error>) -> Void) {
        var query = reference as Query
        queryItems.forEach {
            query = query.whereField($0.key, isEqualTo: $0.value)
        }
        query = query.limit(to: 1)
        FirestoreRepo.fetch(query: query, completion: completion)
    }

    func search(_ queryItems: [Contact.Payload.QueryFilter], limit: Int) async -> [Contact.Payload] {
        var query = reference as Query
        queryItems.forEach {
            query = query
                .whereField($0.key, isGreaterThanOrEqualTo: $0.value)
                .whereField($0.key, isLessThan: $0.value + "\u{f8ff}")
        }
        query = query.limit(to: limit)
        return await FirestoreRepo.fetch(query: query)
    }
}


extension Contact.Payload {

    enum QueryFilter: Hashable, Identifiable {
        var id: Contact.Payload.QueryFilter { self }
        case id(String)
        case phone(String)

        var key: String {
            switch self {
            case .id:
                return "id"
            case .phone:
                return "phone"
            }
        }

        var value: String {
            switch self {
            case .id(let string):
                return string
            case .phone(let string):
                return string
            }
        }
    }
}
