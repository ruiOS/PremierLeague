//
//  MockTeamsNavigator.swift
//  main
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

@testable import PremierLeague

final class MockTeamsNavigator: TeamsNavigatable {
    private(set) var showSquadCalled = false
    private(set) var showSquadCalledCount = 0
    private(set) var capturedSelectedTeam: FPLTeam?

    func showSquad(for team: FPLTeam) {
        showSquadCalled = true
        showSquadCalledCount += 1
        capturedSelectedTeam = team
    }
}
