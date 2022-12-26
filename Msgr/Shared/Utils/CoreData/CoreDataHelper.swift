//
//  CoreDataFetcher.swift
//  Msgr
//
//  Created by Aung Ko Min on 16/12/22.
//

import Foundation
import CoreData

extension NSManagedObject {

    static func hasSaved(for id: String, _ context: NSManagedObjectContext = Persistance.shared.viewContext) -> Bool {
        let request = Self.fetchRequest() as! NSFetchRequest<NSManagedObject>
        request.predicate = NSPredicate(format: "id == %@", id)
        request.resultType = .countResultType
        request.fetchLimit = 1
        let result = (try? context.count(for: request)) ?? 0
        return result > 0
    }

    @discardableResult
    static func object(for id: String, _ context: NSManagedObjectContext) -> Self? {
        let request = Self.fetchRequest() as! NSFetchRequest<NSManagedObject>
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 2
        do {
            let results = try context.fetch(request)
            return results.first as? Self ?? results.last as? Self
        } catch {
            Log(error)
            return nil
        }
    }

    static func object(with objectID: NSManagedObjectID, context: NSManagedObjectContext?) -> Self? {
        return (try? context?.existingObject(with: objectID) as? Self) ?? context?.object(with: objectID) as? Self
    }
}
