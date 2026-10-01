//
//  CDPlayerRepository.swift
//  main
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import CoreData

// MARK: - PlayerRepository
protocol PlayerRepository {
    func getPlayers(forTeamId teamId: Int, searchQuery: String) -> [FPLPlayer]
}

// MARK: - CDPlayerRepository
struct CDPlayerRepository: PlayerRepository {
    let context: NSManagedObjectContext
    let storage: PersistentStoragable

    init(
        context: NSManagedObjectContext? = nil,
        storage: PersistentStoragable = PersistentStorage.shared
    ) {
        self.storage = storage
        self.context = context ?? storage.context
    }

    func create(record: FPLPlayer) {
        let cdPlayer = CDPlayer(context: context)
        cdPlayer.bind(player: record)
    }

    func getPlayers(forTeamId teamId: Int, searchQuery: String = "") -> [FPLPlayer] {
        var predicates: [NSPredicate] = [NSPredicate(format: "teamId == %d", teamId)]
        
        let trimmed = searchQuery.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            predicates.append(NSPredicate(
                format: "webName CONTAINS[cd] %@ OR firstName CONTAINS[cd] %@ OR secondName CONTAINS[cd] %@",
                trimmed, trimmed, trimmed
            ))
        }
        
        let sortDescriptors = [
            NSSortDescriptor(key: "elementType", ascending: true),
            NSSortDescriptor(key: "totalPoints", ascending: false)
        ]
        
        let fetchResult: [CDPlayer] = storage.fetchObjects(
            in: context,
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates),
            sortDescriptors: sortDescriptors
        )
        return fetchResult.map { $0.convertToFPLPlayer() }
    }

    func deleteAll() {
        let stores = context.persistentStoreCoordinator?.persistentStores ?? []
        let hasOnlySQLiteStores = !stores.isEmpty && stores.allSatisfy { $0.type == NSSQLiteStoreType }

        if hasOnlySQLiteStores {
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: CDPlayer.entityName))
            deleteRequest.resultType = .resultTypeCount
            _ = try? context.execute(deleteRequest)
        } else {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CDPlayer.entityName)
            if let objects = try? context.fetch(fetchRequest) {
                for object in objects {
                    context.delete(object)
                }
            }
        }
    }
}
