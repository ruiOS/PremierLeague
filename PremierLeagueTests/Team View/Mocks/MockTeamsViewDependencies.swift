//
//  MockTeamsViewDependencies.swift
//  PremierLeagueTests
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import Foundation
@testable import PremierLeague

struct MockTeamsViewDependencies: TeamsViewDependable {
    var dataService: FPLDataServicable
    var teamRepository: TeamRepository
    var playerRepository: PlayerRepository

    init(
        dataService: FPLDataServicable = MockFPLDataService(),
        teamRepository: TeamRepository = MockTeamRepository(),
        playerRepository: PlayerRepository = MockPlayerRepository()
    ) {
        self.dataService = dataService
        self.teamRepository = teamRepository
        self.playerRepository = playerRepository
    }
}
