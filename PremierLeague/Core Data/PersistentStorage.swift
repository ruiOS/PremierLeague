//
//  PersistentStorage.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 30/09/26.
//

import CoreData

// MARK: - StorageContext
enum StorageContext {
    case main
    case background(NSManagedObjectContext)
}

// MARK: - PersistentStoragable
protocol PersistentStoragable: Sendable {
    var context: NSManagedObjectContext { get }
    func getBackgroundContext() -> NSManagedObjectContext
    func save(context: StorageContext) throws
    func reset(context: StorageContext)
    func fetchObjects<T: EntityIdentifiable>(
        in targetContext: NSManagedObjectContext?,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]?
    ) -> [T]
    func count<T: EntityIdentifiable>(
        in targetContext: NSManagedObjectContext?,
        for entityType: T.Type,
        predicate: NSPredicate?
    ) -> Int
}

extension PersistentStoragable {
    func fetchObjects<T: EntityIdentifiable>(
        in targetContext: NSManagedObjectContext? = nil,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) -> [T] {
        fetchObjects(in: targetContext, predicate: predicate, sortDescriptors: sortDescriptors)
    }

    func count<T: EntityIdentifiable>(
        in targetContext: NSManagedObjectContext? = nil,
        for entityType: T.Type,
        predicate: NSPredicate? = nil
    ) -> Int {
        count(in: targetContext, for: entityType, predicate: predicate)
    }
}

final class PersistentStorage: PersistentStoragable, @unchecked Sendable {

    // MARK: Core Data stack
    let persistentContainer: NSPersistentContainer
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: Singleton
    static let shared: PersistentStorage = PersistentStorage()

    private init() {
        let containerName = "PremierLeague"
        let container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self.persistentContainer = container
    }

    // MARK: BG Stack
    func getBackgroundContext() -> NSManagedObjectContext {
        let bg = persistentContainer.newBackgroundContext()
        bg.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return bg
    }

    // MARK: Context-based Operations
    private func resolveContext(_ storageContext: StorageContext) -> NSManagedObjectContext {
        switch storageContext {
        case .main:
            return context
        case .background(let ctx):
            return ctx
        }
    }

    func save(context: StorageContext) throws {
        let ctx = resolveContext(context)
        if ctx.hasChanges {
            try ctx.save()
        }
    }

    func reset(context: StorageContext) {
        let ctx = resolveContext(context)
        ctx.reset()
    }

    // MARK: Query Helpers
    func fetchObjects<T: EntityIdentifiable>(
        in targetContext: NSManagedObjectContext? = nil,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) -> [T] {
        let ctx = targetContext ?? context
        let fetchRequest = NSFetchRequest<T>(entityName: T.entityName)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors

        do {
            return try ctx.fetch(fetchRequest)
        } catch {
            debugPrint("Failed to fetch \(T.entityName): \(error)")
            return []
        }
    }

    func count<T: EntityIdentifiable>(
        in targetContext: NSManagedObjectContext? = nil,
        for entityType: T.Type,
        predicate: NSPredicate? = nil
    ) -> Int {
        let ctx = targetContext ?? context
        let fetchRequest = NSFetchRequest<T>(entityName: T.entityName)
        fetchRequest.predicate = predicate

        do {
            return try ctx.count(for: fetchRequest)
        } catch {
            debugPrint("Failed to count \(T.entityName): \(error)")
            return 0
        }
    }
}
