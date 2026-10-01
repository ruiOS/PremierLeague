//
//  TestFixtures.swift
//  PremierLeagueTests
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

@testable import PremierLeague

// MARK: - Shared Test Fixtures

enum TestFixtures {
    static let sampleTeams: [FPLTeam] = [
        FPLTeam(id: 1, name: "Arsenal", shortName: "ARS", computedPlayerCount: 25),
        FPLTeam(id: 2, name: "Aston Villa", shortName: "AVL", computedPlayerCount: 24),
        FPLTeam(id: 3, name: "Chelsea", shortName: "CHE", computedPlayerCount: 28)
    ]

    static let samplePlayers: [FPLPlayer] = [
        FPLPlayer(id: 101, firstName: "David", secondName: "Raya", webName: "Raya", team: 1, elementType: .goalkeeper, nowCost: 55, totalPoints: 120, status: .available),
        FPLPlayer(id: 102, firstName: "William", secondName: "Saliba", webName: "Saliba", team: 1, elementType: .defender, nowCost: 60, totalPoints: 140, status: .available),
        FPLPlayer(id: 103, firstName: "Gabriel", secondName: "Magalhães", webName: "Gabriel", team: 1, elementType: .defender, nowCost: 60, totalPoints: 135, status: .available),
        FPLPlayer(id: 104, firstName: "Bukayo", secondName: "Saka", webName: "Saka", team: 1, elementType: .midfielder, nowCost: 100, totalPoints: 180, status: .available),
        FPLPlayer(id: 105, firstName: "Kai", secondName: "Havertz", webName: "Havertz", team: 1, elementType: .forward, nowCost: 80, totalPoints: 130, status: .available)
    ]
}
