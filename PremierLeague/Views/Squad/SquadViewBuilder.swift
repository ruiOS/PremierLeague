//
//  SquadViewBuilder.swift
//  main
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import UIKit

struct SquadViewBuilder {

    func build(for team: FPLTeam) -> UIViewController {
        let squadVM = SquadViewModel(team: team)
        let squadVC = SquadViewController(viewModel: squadVM)
        return squadVC
    }
}
