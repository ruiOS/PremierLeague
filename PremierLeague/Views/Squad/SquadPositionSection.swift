//
//  SquadPositionSection.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import Foundation

struct SquadPositionSection: Identifiable, Equatable, Sendable {
    var id: Int { positionId }
    let positionId: Int
    let title: String
    let players: [FPLPlayer]
}
