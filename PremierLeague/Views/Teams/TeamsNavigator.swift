//
//  TeamsNavigator.swift
//  main
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import UIKit

// MARK: - Navigation Protocol
protocol TeamsNavigatable: AnyObject {
    func showSquad(for team: FPLTeam)
}

// MARK: - Navigator
final class TeamsNavigator: TeamsNavigatable {
    private weak var viewController: UIViewController?

    func setViewController(_ viewController: UIViewController) {
        self.viewController = viewController
    }

    func showSquad(for team: FPLTeam) {
        let squadVC = SquadViewBuilder().build(for: team)
        viewController?.navigationController?.pushViewController(squadVC, animated: true)
    }
}
