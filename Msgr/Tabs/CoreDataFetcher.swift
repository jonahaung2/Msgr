//
//  CoreDataFetcher.swift
//  Msgr
//
//  Created by Aung Ko Min on 13/12/22.
//

import Foundation
import CoreData

class CoreDataFetcher<T>: NSObject, ObservableObject, NSFetchedResultsControllerDelegate where T: NSManagedObject {

    @Published var items = [T]()

    private var frc: NSFetchedResultsController<T>

    init(predicate: (key: String, sign: String, value: AnyHashable)? = nil, sortDescriptor: (key: String, accending: Bool)) {
        let request = T.fetchRequest() as! NSFetchRequest<T>
        request.sortDescriptors = [NSSortDescriptor(key: sortDescriptor.key, ascending: sortDescriptor.accending)]
        if let predicate {
            request.predicate = NSPredicate(format: "\(predicate.key) \(predicate.sign) \(predicate.value)")
        }
        frc = NSFetchedResultsController<T>(fetchRequest: request, managedObjectContext: Persistance.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        super.init()
        frc.delegate = self
        fetch()
    }

    private func fetch() {
        do {
            try frc.performFetch()
            items = frc.fetchedObjects ?? []
        } catch {
            Log(error)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        items = frc.fetchedObjects ?? []
    }
}
