//
//  TeamsViewModel.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 30/09/26.
//

import Foundation

// MARK: - TeamsViewModelable
protocol TeamsViewModelable: AnyObject {

    var numberOfTeams: Int { get }

    var stateDidChange: ((TeamsViewState) -> Void)? { get set }
    var contentDidChange: (() -> Void)? { get set }
    var refreshDidFail: ((NetworkCallError) -> Void)? { get set }

    func team(at row: Int) -> FPLTeam
    func loadTeams(for loadState: TeamsLoadTrigger)
    func didSelectTeam(at row: Int)
}

// MARK: - TeamsViewModel
final class TeamsViewModel {
    
    // MARK: Data
    private var fetchedTeams: [FPLTeam] = []
    private let dependencies: TeamsViewDependable
    private let navigator: TeamsNavigatable

    // MARK: State
    var stateDidChange: ((TeamsViewState) -> Void)?
    var contentDidChange: (() -> Void)?
    var refreshDidFail: ((NetworkCallError) -> Void)?
    
    private(set) var state: TeamsViewState = .loading {
        didSet { stateDidChange?(state) }
    }

    // MARK: Init
    init(dependencies: TeamsViewDependable = TeamsViewDependencies(),
         navigator: TeamsNavigatable) {
        self.dependencies = dependencies
        self.navigator = navigator
        loadLocalTeams()
    }

    // MARK: Data Loading
    private func loadLocalTeams() {
        self.fetchedTeams = dependencies.teamRepository.getAll()
        contentDidChange?()
    }
}

// MARK: TeamsViewModelable
extension TeamsViewModel: TeamsViewModelable {

    var numberOfTeams: Int {
        fetchedTeams.count
    }

    func team(at row: Int) -> FPLTeam {
        fetchedTeams[row]
    }

    func loadTeams(for loadState: TeamsLoadTrigger) {
        prepareInitialState(for: loadState)

        Task { [weak self] in
            guard let self else { return }
            await self.performFetch(for: loadState)
        }
    }

    func didSelectTeam(at row: Int) {
        let selectedTeam = team(at: row)
        navigator.showSquad(for: selectedTeam)
    }
}

// MARK: Private Helpers
private extension TeamsViewModel {

    func prepareInitialState(for trigger: TeamsLoadTrigger) {
        switch trigger {
        case .pullToRefresh:
            break
        case .standard:
            let hasCachedData = dependencies.dataService.storedDataStatus().hasData
            state = hasCachedData ? .loaded : .loading
        }
    }

    func performFetch(for trigger: TeamsLoadTrigger) async {
        do {
            try await dependencies.dataService.fetchAndPersist()
            loadLocalTeams()
            state = .loaded
        } catch let error as NetworkCallError {
            handleNetworkError(error, for: trigger)
        } catch {
            handleGenericError(error, for: trigger)
        }
    }

    func handleNetworkError(_ error: NetworkCallError, for trigger: TeamsLoadTrigger) {
        guard error != .notModified else {
            state = .loaded
            return
        }

        switch trigger {
        case .pullToRefresh:
            loadLocalTeams()
            state = .loaded
            refreshDidFail?(error)
        case .standard:
            state = .failed(error)
        }
    }

    func handleGenericError(_ error: Error, for trigger: TeamsLoadTrigger) {
        switch trigger {
        case .pullToRefresh:
            break
        case .standard:
            state = .failed(.serverSideError(error.localizedDescription))
        }
    }
}
