//
//  MockTeamRepository.swift
//  main
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

@testable import PremierLeague

final class MockTeamRepository: TeamRepository {
    var getAllReturnValue: [FPLTeam] = []
    private(set) var getAllCalled = false
    private(set) var getAllCalledCount = 0

    func getAll() -> [FPLTeam] {
        getAllCalled = true
        getAllCalledCount += 1
        return getAllReturnValue
    }
}
