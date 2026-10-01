//
//  MockPlayerRepository.swift
//  main
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

@testable import PremierLeague

final class MockPlayerRepository: PlayerRepository {
    var getPlayerCountReturnValue: Int = 0
    private(set) var getPlayerCountCalled = false
    private(set) var getPlayerCountCalledCount = 0
    private(set) var capturedTeamIdForPlayerCount: Int?

    var getPlayersReturnValue: [FPLPlayer] = []
    private(set) var getPlayersCalled = false
    private(set) var getPlayersCalledCount = 0
    private(set) var capturedTeamIdForPlayers: Int?
    private(set) var capturedSearchQuery: String?

    func getPlayerCount(forTeamId teamId: Int) -> Int {
        getPlayerCountCalled = true
        getPlayerCountCalledCount += 1
        capturedTeamIdForPlayerCount = teamId
        return getPlayerCountReturnValue
    }

    func getPlayers(forTeamId teamId: Int, searchQuery: String) -> [FPLPlayer] {
        getPlayersCalled = true
        getPlayersCalledCount += 1
        capturedTeamIdForPlayers = teamId
        capturedSearchQuery = searchQuery
        return getPlayersReturnValue
    }
}
