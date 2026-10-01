//
//  SquadViewModelTests.swift
//  PremierLeagueTests
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import XCTest
@testable import PremierLeague

@MainActor
final class SquadViewModelTests: XCTestCase {

    private var sut: SquadViewModel!
    private var mockPlayerRepo: MockPlayerRepository!
    private let testTeam = FPLTeam(id: 1, name: "Arsenal", shortName: "ARS", computedPlayerCount: 4)
    private let samplePlayers = TestFixtures.samplePlayers

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockPlayerRepo = MockPlayerRepository()
    }

    override func tearDownWithError() throws {
        sut = nil
        mockPlayerRepo = nil
        try super.tearDownWithError()
    }

    private func createSUT() -> SquadViewModel {
        let dependencies = MockSquadViewDependencies(playerRepository: mockPlayerRepo)
        return SquadViewModel(team: testTeam, dependencies: dependencies)
    }

    // MARK: - Initialisation & Grouping Tests

    func testInitializationGroupsPlayersByPositionAscending() {
        // Arrange
        mockPlayerRepo.getPlayersReturnValue = samplePlayers

        // Act
        sut = createSUT()

        // Assert
        XCTAssertTrue(mockPlayerRepo.getPlayersCalled)
        XCTAssertEqual(mockPlayerRepo.capturedTeamIdForPlayers, 1)
        XCTAssertEqual(sut.teamName, "Arsenal")
        XCTAssertEqual(sut.contentState, .populated)
        XCTAssertEqual(sut.numberOfSections, 4)

        // Goalkeepers (1)
        XCTAssertEqual(sut.sectionTitle(for: 0), "Goalkeepers")
        XCTAssertEqual(sut.numberOfPlayers(in: 0), 1)
        XCTAssertEqual(sut.player(at: IndexPath(row: 0, section: 0)).webName, "Raya")

        // Defenders (2)
        XCTAssertEqual(sut.sectionTitle(for: 1), "Defenders")
        XCTAssertEqual(sut.numberOfPlayers(in: 1), 2)
        XCTAssertEqual(sut.player(at: IndexPath(row: 0, section: 1)).webName, "Saliba")
        XCTAssertEqual(sut.player(at: IndexPath(row: 1, section: 1)).webName, "Gabriel")

        // Midfielders (3)
        XCTAssertEqual(sut.sectionTitle(for: 2), "Midfielders")
        XCTAssertEqual(sut.numberOfPlayers(in: 2), 1)
        XCTAssertEqual(sut.player(at: IndexPath(row: 0, section: 2)).webName, "Saka")

        // Forwards (4)
        XCTAssertEqual(sut.sectionTitle(for: 3), "Forwards")
        XCTAssertEqual(sut.numberOfPlayers(in: 3), 1)
        XCTAssertEqual(sut.player(at: IndexPath(row: 0, section: 3)).webName, "Havertz")
    }

    func testInitializationWithNoPlayersYieldsEmptyState() {
        // Arrange
        mockPlayerRepo.getPlayersReturnValue = []

        // Act
        sut = createSUT()

        // Assert
        XCTAssertEqual(sut.numberOfSections, 0)
        XCTAssertEqual(sut.contentState, .empty)
    }

    // MARK: - Search Query Tests

    func testUpdateSearchFiltersSquadAndTriggersNotification() {
        // Arrange
        mockPlayerRepo.getPlayersReturnValue = samplePlayers
        sut = createSUT()

        var notified = false
        sut.sectionsDidChange = {
            notified = true
        }

        let filteredPlayers = [samplePlayers[3]] // Saka
        mockPlayerRepo.getPlayersReturnValue = filteredPlayers

        // Act
        sut.updateSearch(query: "Saka")

        // Assert
        XCTAssertTrue(notified)
        XCTAssertEqual(sut.searchQuery, "Saka")
        XCTAssertEqual(mockPlayerRepo.capturedSearchQuery, "Saka")
        XCTAssertEqual(sut.numberOfSections, 1)
        XCTAssertEqual(sut.sectionTitle(for: 0), "Midfielders")
        XCTAssertEqual(sut.numberOfPlayers(in: 0), 1)
        XCTAssertEqual(sut.player(at: IndexPath(row: 0, section: 0)).webName, "Saka")
    }

    func testSectionPlayerCountMatchesNumberOfPlayers() {
        // Arrange
        mockPlayerRepo.getPlayersReturnValue = samplePlayers
        sut = createSUT()

        // Assert
        XCTAssertEqual(sut.sectionPlayerCount(for: 1), 2)
        XCTAssertEqual(sut.numberOfPlayers(in: 1), 2)
    }

    func testUpdateSearchWithNoMatchesTransitionsToEmptyState() {
        // Arrange
        mockPlayerRepo.getPlayersReturnValue = samplePlayers
        sut = createSUT()
        XCTAssertEqual(sut.contentState, .populated)

        mockPlayerRepo.getPlayersReturnValue = []

        // Act
        sut.updateSearch(query: "NonExistentPlayer")

        // Assert
        XCTAssertEqual(sut.numberOfSections, 0)
        XCTAssertEqual(sut.contentState, .empty)
    }

    func testUpdateSearchWithEmptyQueryRestoresAllPlayers() {
        // Arrange
        mockPlayerRepo.getPlayersReturnValue = samplePlayers
        sut = createSUT()

        // Filter first
        mockPlayerRepo.getPlayersReturnValue = [samplePlayers[0]]
        sut.updateSearch(query: "Raya")
        XCTAssertEqual(sut.numberOfSections, 1)

        // Clear search
        mockPlayerRepo.getPlayersReturnValue = samplePlayers
        sut.updateSearch(query: "")

        // Assert
        XCTAssertEqual(sut.searchQuery, "")
        XCTAssertEqual(sut.numberOfSections, 4)
        XCTAssertEqual(sut.contentState, .populated)
    }
}
