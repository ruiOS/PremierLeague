//
//  CDTeamRepository.swift
//  main
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import CoreData

protocol TeamRepository {
    func getAll() -> [FPLTeam]
}

// MARK: - CDTeamRepository
struct CDTeamRepository: TeamRepository {
    private let context: NSManagedObjectContext
    private let storage: PersistentStoragable

    init(
        context: NSManagedObjectContext? = nil,
        storage: PersistentStoragable = PersistentStorage.shared
    ) {
        self.storage = storage
        self.context = context ?? storage.context
    }

    func create(record: FPLTeam) {
        let cdTeam = CDTeam(context: context)
        cdTeam.bind(team: record, playerCount: record.computedPlayerCount)
    }

    func getAll() -> [FPLTeam] {
        let sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        let cdTeams: [CDTeam] = storage.fetchObjects(in: context, sortDescriptors: sortDescriptors)
        return cdTeams.map { $0.convertToFPLTeam() }
    }

    func storedDataStatus() -> CacheState {
        storage.count(in: context, for: CDTeam.self) > 0 ? .available : .empty
    }

    func deleteAll() {
        let stores = context.persistentStoreCoordinator?.persistentStores ?? []
        let hasOnlySQLiteStores = !stores.isEmpty && stores.allSatisfy { $0.type == NSSQLiteStoreType }

        if hasOnlySQLiteStores {
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: CDTeam.entityName))
            deleteRequest.resultType = .resultTypeCount
            _ = try? context.execute(deleteRequest)
        } else {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CDTeam.entityName)
            if let objects = try? context.fetch(fetchRequest) {
                for object in objects {
                    context.delete(object)
                }
            }
        }
    }
}
