//
//  FirestoreRepo.swift
//  Msgr
//
//  Created by Aung Ko Min on 4/11/22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct FirestoreRepo {

    static func add<T: Codable & Identifiable>(_ item: T, to ref: CollectionReference, completion: ((Error?)-> Void)? = nil) {
        do {
            _ = try ref.addDocument(from: item, completion: completion)
        } catch {
            completion?(error)
        }
    }

    static func update<T: Codable & Identifiable>(_ item: T, to ref: CollectionReference, completion: ((Error?)-> Void)? = nil) {
        guard let id = item.id as? String else {
            completion?(nil)
            return
        }
        do {
            _ = try ref.document(id).setData(from: item, completion: completion)
        } catch {
            completion?(error)
        }
    }

    static func remove<T: Codable & Identifiable>(_ item: T, to ref: CollectionReference, completion: ((Error?)-> Void)? = nil) {
        guard let id = item.id as? String else {
            completion?(nil)
            return
        }
        ref.document(id).delete(completion: completion)
    }

    static func fetch<T: Codable>(query: Query) async -> [T] {
        do {
            let snapshot = try await query.getDocuments()
            return snapshot.documents.compactMap { try? $0.data(as: T.self)}
        } catch {
            print(error)
            return []
        }
    }

    static func fetch<T: Codable>(query: Query, completion: @escaping (Result<[T], Error>) -> Void) {
        query.getDocuments { snapshot, error in
            if let error {
                completion(.failure(error))
            } else if let snapshot {
                let items = snapshot.documents.compactMap { try? $0.data(as: T.self)}
                completion(.success(items))
            }
        }
    }
    static func fetch<T: Codable>(query: Query, completion: @escaping (Result<T?, Error>) -> Void) {
        query.getDocuments { snapshot, error in
            if let error {
                completion(.failure(error))
            } else if let snapshot {
                let items = snapshot.documents.compactMap { try? $0.data(as: T.self)}
                completion(.success(items.first))
            }
        }
    }
}
