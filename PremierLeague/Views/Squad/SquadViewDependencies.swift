//
//  SquadViewDependencies.swift
//  main
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import Foundation

protocol SquadViewDependable {
    var playerRepository: PlayerRepository { get }
}

struct SquadViewDependencies: SquadViewDependable {
    let playerRepository: PlayerRepository = CDPlayerRepository()
}
