//
//  FPLDataService.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 30/09/26.
//

import CoreData

// MARK: - FPLDataServicable
protocol FPLDataServicable {
    func storedDataStatus() -> CacheState
    func fetchAndPersist() async throws
    func clearAllData()
}

// MARK: - FPLDataService
final class FPLDataService: FPLDataServicable {

    // MARK: Dependencies
    private let dependencies: FPLDataServiceDependable

    init(dependencies: FPLDataServiceDependable = FPLDataServiceDependencies()) {
        self.dependencies = dependencies
    }

    // MARK: FPLDataServicable
    func storedDataStatus() -> CacheState {
        let teamRepo = CDTeamRepository(context: dependencies.storage.context, storage: dependencies.storage)
        return teamRepo.storedDataStatus()
    }

    func fetchAndPersist() async throws {
        let savedEtag = dependencies.cacheSettings.getETag()
        let result = try await dependencies.apiService.fetchBootstrapData(etag: savedEtag)
        
        guard let response = result.response else {
            throw NetworkCallError.notModified
        }
        
        if let newEtag = result.newEtag {
            dependencies.cacheSettings.saveETag(newEtag)
        }
        
        try await batchInsert(response: response)
    }

    func clearAllData() {
        let context = dependencies.storage.context
        let teamRepo = CDTeamRepository(context: context, storage: dependencies.storage)
        let playerRepo = CDPlayerRepository(context: context, storage: dependencies.storage)

        teamRepo.deleteAll()
        playerRepo.deleteAll()

        dependencies.storage.reset(context: .main)
    }

    // MARK: Batch insert
    private func batchInsert(response: FPLBootstrapResponse) async throws {
        let bgContext = dependencies.storage.getBackgroundContext()

        let playerCountPerTeam: [Int: Int] = Dictionary(
            response.elements.map { ($0.team, 1) },
            uniquingKeysWith: +
        )

        let storage = dependencies.storage

        try await bgContext.perform {
            let teamRepo = CDTeamRepository(context: bgContext, storage: storage)
            let playerRepo = CDPlayerRepository(context: bgContext, storage: storage)

            teamRepo.deleteAll()
            for var t in response.teams {
                t.computedPlayerCount = playerCountPerTeam[t.id] ?? 0
                teamRepo.create(record: t)
            }
            try storage.save(context: .background(bgContext))
            storage.reset(context: .background(bgContext))

            playerRepo.deleteAll()
            let batchSize = 500
            var count = 0

            for p in response.elements {
                playerRepo.create(record: p)
                
                count += 1
                if count % batchSize == 0 {
                    try storage.save(context: .background(bgContext))
                    storage.reset(context: .background(bgContext))
                }
            }

            try storage.save(context: .background(bgContext))
            storage.reset(context: .background(bgContext))
        }
    }
}
