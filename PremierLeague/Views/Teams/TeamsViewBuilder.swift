//
//  TeamsViewBuilder.swift
//  main
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import UIKit

struct TeamsViewBuilder {

    func build() -> UIViewController {
        let navigator = TeamsNavigator()
        let teamsViewModel = TeamsViewModel(navigator: navigator)
        let teamsViewController = TeamsViewController(viewModel: teamsViewModel)
        navigator.setViewController(teamsViewController)
        return teamsViewController
    }
}
