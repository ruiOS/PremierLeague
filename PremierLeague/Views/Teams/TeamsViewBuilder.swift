//
//  TeamsViewBuilder.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import SwiftUI

struct TeamsViewBuilder {

    func build() -> TeamsView {
        let navigator = TeamsNavigator()
        let teamsViewModel = TeamsViewModel(navigator: navigator)
        return TeamsView(viewModel: teamsViewModel, navigator: navigator)
    }
}
