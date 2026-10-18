//
//  SquadViewModel.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 30/09/26.
//

import Foundation
import Combine
import UIKit

// MARK: - SquadViewModelable
protocol SquadViewModelable: AnyObject {

    var teamName: String { get }
    var numberOfSections: Int { get }
    var contentState: SquadViewState { get }
    var sections: [SquadPositionSection] { get }

    var sectionsDidChange: (() -> Void)? { get set }

    func numberOfPlayers(in section: Int) -> Int
    func player(at indexPath: IndexPath) -> FPLPlayer
    func sectionTitle(for section: Int) -> String
    func sectionPlayerCount(for section: Int) -> Int
    func updateSearch(query: String)
}

// MARK: - SquadViewModel
final class SquadViewModel: ObservableObject {

    // MARK: Dependencies
    private let team: FPLTeam
    private let dependencies: SquadViewDependable

    // MARK: Data
    @Published private(set) var searchQuery = ""
    @Published private(set) var groupedSections: [SquadPositionSection] = []

    var sections: [SquadPositionSection] { groupedSections }

    // MARK: State
    var sectionsDidChange: (() -> Void)?

    // MARK: Init
    init(
        team: FPLTeam,
        dependencies: SquadViewDependable = SquadViewDependencies()
    ) {
        self.team = team
        self.dependencies = dependencies
        buildSections(query: "")
    }

    // MARK: Data Fetching
    private func buildSections(query: String) {
        let players = dependencies.playerRepository.getPlayers(forTeamId: team.id, searchQuery: query)
        
        let grouped = Dictionary(grouping: players, by: { $0.elementType })
        let sortedPositions = grouped.keys.sorted()
        
        groupedSections = sortedPositions.map { position in
            SquadPositionSection(
                positionId: position.rawValue,
                title: position.pluralName,
                players: grouped[position] ?? []
            )
        }
    }
}

// MARK: SquadViewModelable
extension SquadViewModel: SquadViewModelable {

    var teamName: String { team.name }

    var numberOfSections: Int { groupedSections.count }

    var contentState: SquadViewState { numberOfSections == 0 ? .empty : .populated }

    func numberOfPlayers(in section: Int) -> Int {
        groupedSections[section].players.count
    }

    func player(at indexPath: IndexPath) -> FPLPlayer {
        groupedSections[indexPath.section].players[indexPath.row]
    }

    func sectionTitle(for section: Int) -> String {
        groupedSections[section].title
    }

    func sectionPlayerCount(for section: Int) -> Int {
        groupedSections[section].players.count
    }

    func updateSearch(query: String) {
        searchQuery = query
        buildSections(query: query)
        sectionsDidChange?()
    }
}
