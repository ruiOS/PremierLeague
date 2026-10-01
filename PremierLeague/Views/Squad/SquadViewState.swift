//
//  SquadViewState.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import Foundation

enum SquadViewState: Equatable {
    case empty
    case populated

    var isEmpty: Bool {
        self == .empty
    }

    var isPopulated: Bool {
        self == .populated
    }
}
