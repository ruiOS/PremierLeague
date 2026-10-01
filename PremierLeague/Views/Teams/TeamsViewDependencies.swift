//
//  TeamsViewDependencies.swift
//  main
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import Foundation

// MARK: - TeamsViewDependable
protocol TeamsViewDependable {
    var dataService: FPLDataServicable { get }
    var teamRepository: TeamRepository { get }
    var playerRepository: PlayerRepository { get }
}

// MARK: - TeamsViewDependencies
struct TeamsViewDependencies: TeamsViewDependable {
    let dataService: FPLDataServicable = FPLDataService()
    let teamRepository: TeamRepository = CDTeamRepository()
    let playerRepository: PlayerRepository = CDPlayerRepository()
}
