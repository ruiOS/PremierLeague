//
//  TeamsViewModelTests.swift
//  PremierLeagueTests
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import XCTest
@testable import PremierLeague

@MainActor
final class TeamsViewModelTests: XCTestCase {

    private var sut: TeamsViewModel!
    private var mockNavigator: MockTeamsNavigator!
    private var mockDataService: MockFPLDataService!
    private var mockTeamRepo: MockTeamRepository!
    private var mockPlayerRepo: MockPlayerRepository!

    private let sampleTeams = TestFixtures.sampleTeams

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockNavigator = MockTeamsNavigator()
        mockDataService = MockFPLDataService()
        mockTeamRepo = MockTeamRepository()
        mockPlayerRepo = MockPlayerRepository()
    }

    override func tearDownWithError() throws {
        sut = nil
        mockNavigator = nil
        mockDataService = nil
        mockTeamRepo = nil
        mockPlayerRepo = nil
        try super.tearDownWithError()
    }

    private func createSUT() -> TeamsViewModel {
        let dependencies = MockTeamsViewDependencies(
            dataService: mockDataService,
            teamRepository: mockTeamRepo,
            playerRepository: mockPlayerRepo
        )
        return TeamsViewModel(dependencies: dependencies, navigator: mockNavigator)
    }

    // MARK: Initialisation & Local Cache Loading Tests
    func testInitializationLoadsLocalTeamsAndNotifiesContentChange() {
        mockTeamRepo.getAllReturnValue = sampleTeams
        var contentChanged = false

        let dependencies = MockTeamsViewDependencies(
            dataService: mockDataService,
            teamRepository: mockTeamRepo,
            playerRepository: mockPlayerRepo
        )
        sut = TeamsViewModel(dependencies: dependencies, navigator: mockNavigator)
        sut.contentDidChange = {
            contentChanged = true
        }

        sut.contentDidChange?()

        // Assert
        XCTAssertTrue(mockTeamRepo.getAllCalled)
        XCTAssertTrue(contentChanged)
        XCTAssertEqual(sut.numberOfTeams, 3)
        XCTAssertEqual(sut.team(at: 0).name, "Arsenal")
        XCTAssertEqual(sut.team(at: 1).name, "Aston Villa")
        XCTAssertEqual(sut.team(at: 2).name, "Chelsea")
    }

    // MARK: - Player Count Tests

    func testTeamReturnsComputedPlayerCount() {
        mockTeamRepo.getAllReturnValue = sampleTeams
        sut = createSUT()

        let count = sut.team(at: 0).computedPlayerCount

        XCTAssertEqual(count, 25)
    }

    // MARK: - Navigation Tests

    func testDidSelectTeamNavigatesToSquadView() {
        mockTeamRepo.getAllReturnValue = sampleTeams
        sut = createSUT()

        sut.didSelectTeam(at: 1)

        XCTAssertTrue(mockNavigator.showSquadCalled)
        XCTAssertEqual(mockNavigator.showSquadCalledCount, 1)
        XCTAssertEqual(mockNavigator.capturedSelectedTeam?.id, 2)
        XCTAssertEqual(mockNavigator.capturedSelectedTeam?.name, "Aston Villa")
    }

    // MARK: - Standard Load Tests

    func testLoadTeamsStandardWithNoCachedDataSetsInitialLoadingState() {
        mockDataService.storedDataStatusReturnValue = .empty
        mockTeamRepo.getAllReturnValue = []
        sut = createSUT()

        sut.loadTeams(for: .standard)

        XCTAssertEqual(.loading, sut.state)
    }

    func testLoadTeamsStandardWithCachedDataSetsInitialLoadedState() {
        mockDataService.storedDataStatusReturnValue = .available
        mockTeamRepo.getAllReturnValue = sampleTeams
        sut = createSUT()

        sut.loadTeams(for: .standard)

        XCTAssertEqual(.loaded, sut.state)
    }

    func testLoadTeamsStandardSuccessUpdatesStateToLoadedAndRefreshesLocalTeams() async {
        mockDataService.storedDataStatusReturnValue = .empty
        mockTeamRepo.getAllReturnValue = []
        sut = createSUT()

        let expectation = expectation(description: "State changes to loaded")
        sut.stateDidChange = { state in
            if case .loaded = state {
                expectation.fulfill()
            }
        }

        mockTeamRepo.getAllReturnValue = sampleTeams

        sut.loadTeams(for: .standard)

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockDataService.fetchAndPersistCalled)
        XCTAssertEqual(sut.numberOfTeams, 3)
    }

    func testLoadTeamsStandardFailsWithNetworkCallErrorSetsFailedState() async {
        mockDataService.storedDataStatusReturnValue = .empty
        mockDataService.fetchAndPersistResult = .failure(NetworkCallError.noNetworkConnection)
        sut = createSUT()

        let expectation = expectation(description: "State changes to failed")
        sut.stateDidChange = { state in
            if case .failed(let error) = state {
                XCTAssertEqual(error, .noNetworkConnection)
                expectation.fulfill()
            }
        }

        sut.loadTeams(for: .standard)

        await fulfillment(of: [expectation], timeout: 2.0)
    }

    func testLoadTeamsStandardFailsWithNotModifiedSetsLoadedState() async {
        mockDataService.storedDataStatusReturnValue = .empty
        mockDataService.fetchAndPersistResult = .failure(NetworkCallError.notModified)
        mockTeamRepo.getAllReturnValue = sampleTeams
        sut = createSUT()

        let expectation = expectation(description: "State remains or becomes loaded on notModified")
        sut.stateDidChange = { state in
            if case .loaded = state {
                expectation.fulfill()
            }
        }

        sut.loadTeams(for: .standard)

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(.loaded, sut.state)
    }

    func testLoadTeamsStandardFailsWithGenericErrorSetsFailedServerSideError() async {
        struct TestCustomError: LocalizedError {
            var errorDescription: String? { "Something went wrong" }
        }
        mockDataService.storedDataStatusReturnValue = .empty
        mockDataService.fetchAndPersistResult = .failure(TestCustomError())
        sut = createSUT()

        let expectation = expectation(description: "State changes to failed serverSideError")
        sut.stateDidChange = { state in
            if case .failed(let error) = state {
                if case .serverSideError(let message) = error {
                    XCTAssertTrue(message.contains("Something went wrong"))
                    expectation.fulfill()
                }
            }
        }

        sut.loadTeams(for: .standard)

        await fulfillment(of: [expectation], timeout: 2.0)
    }

    // MARK: - Pull to Refresh Tests

    func testLoadTeamsPullToRefreshSuccessRefreshesDataAndSetsLoadedState() async {
        mockDataService.storedDataStatusReturnValue = .available
        mockTeamRepo.getAllReturnValue = [sampleTeams[0]]
        sut = createSUT()

        let expectation = expectation(description: "State transitions to loaded")
        sut.stateDidChange = { state in
            if case .loaded = state {
                expectation.fulfill()
            }
        }

        mockTeamRepo.getAllReturnValue = sampleTeams

        sut.loadTeams(for: .pullToRefresh)

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(sut.numberOfTeams, 3)
    }

    func testLoadTeamsPullToRefreshFailureNotifiesRefreshDidFailAndKeepsLoadedState() async {
        mockDataService.storedDataStatusReturnValue = .available
        mockDataService.fetchAndPersistResult = .failure(NetworkCallError.noDataPresent)
        mockTeamRepo.getAllReturnValue = sampleTeams
        sut = createSUT()

        let refreshFailExpectation = expectation(description: "refreshDidFail is triggered")
        sut.refreshDidFail = { error in
            XCTAssertEqual(error, .noDataPresent)
            refreshFailExpectation.fulfill()
        }

        sut.loadTeams(for: .pullToRefresh)

        await fulfillment(of: [refreshFailExpectation], timeout: 2.0)
        XCTAssertEqual(.loaded, sut.state)
    }
}
