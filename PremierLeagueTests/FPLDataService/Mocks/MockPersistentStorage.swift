//
//  MockPersistentStorage.swift
//  PremierLeagueTests
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import CoreData
@testable import PremierLeague

final class MockPersistentStorage: PersistentStoragable, @unchecked Sendable {
    let persistentContainer: NSPersistentContainer
    private(set) var saveCalled = false
    private(set) var resetCalled = false

    init() {
        let allBundles = Bundle.allBundles + Bundle.allFrameworks
        let modelURL = allBundles.compactMap { $0.url(forResource: "PremierLeague", withExtension: "momd") }.first
            ?? Bundle.main.url(forResource: "PremierLeague", withExtension: "momd")

        if let modelURL = modelURL, let model = NSManagedObjectModel(contentsOf: modelURL) {
            let container = NSPersistentContainer(name: "PremierLeague", managedObjectModel: model)
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [description]
            container.loadPersistentStores { _, _ in }
            self.persistentContainer = container
            return
        }

        let container = NSPersistentContainer(name: "PremierLeague")
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, _ in }
        self.persistentContainer = container
    }

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func getBackgroundContext() -> NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }

    func save(context: StorageContext) throws {
        saveCalled = true
    }

    func reset(context: StorageContext) {
        resetCalled = true
    }

    func fetchObjects<T: EntityIdentifiable>(
        in targetContext: NSManagedObjectContext?,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]?
    ) -> [T] {
        let ctx = targetContext ?? context
        let fetchRequest = NSFetchRequest<T>(entityName: T.entityName)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        return (try? ctx.fetch(fetchRequest)) ?? []
    }

    func count<T: EntityIdentifiable>(
        in targetContext: NSManagedObjectContext?,
        for entityType: T.Type,
        predicate: NSPredicate?
    ) -> Int {
        let ctx = targetContext ?? context
        let fetchRequest = NSFetchRequest<T>(entityName: T.entityName)
        fetchRequest.predicate = predicate
        return (try? ctx.count(for: fetchRequest)) ?? 0
    }
}
