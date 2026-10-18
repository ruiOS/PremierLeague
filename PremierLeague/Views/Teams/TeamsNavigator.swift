//
//  TeamsNavigator.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import Foundation
import Combine

// MARK: - Navigation Protocol
protocol TeamsNavigatable: AnyObject {
    func showSquad(for team: FPLTeam)
}

// MARK: - Navigator
final class TeamsNavigator: ObservableObject, TeamsNavigatable {

    @Published var selectedTeam: FPLTeam?

    func showSquad(for team: FPLTeam) {
        selectedTeam = team
    }
}
