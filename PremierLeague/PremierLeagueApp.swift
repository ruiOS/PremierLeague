//
//  PremierLeagueApp.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 30/09/26.
//

import SwiftUI

@main
struct PremierLeagueApp: App {

    var body: some Scene {
        WindowGroup {
            TeamsViewBuilder().build()
        }
    }
}
