//
//  SquadViewBuilder.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import SwiftUI

struct SquadViewBuilder {

    func build(for team: FPLTeam) -> SquadView {
        let squadVM = SquadViewModel(team: team)
        return SquadView(viewModel: squadVM)
    }
}
