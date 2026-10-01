//
//  SquadMocks.swift
//  PremierLeagueTests
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import Foundation
@testable import PremierLeague

struct MockSquadViewDependencies: SquadViewDependable {
    var playerRepository: PlayerRepository

    init(playerRepository: PlayerRepository = MockPlayerRepository()) {
        self.playerRepository = playerRepository
    }
}
