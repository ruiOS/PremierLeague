//
//  FPLDataServiceTests.swift
//  PremierLeagueTests
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import XCTest
@testable import PremierLeague

@MainActor
final class FPLDataServiceTests: XCTestCase {

    private var mockAPIService: MockAPIService!
    private var mockStorage: MockPersistentStorage!
    private var mockCacheSettings: MockETagStore!
    private var sut: FPLDataService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockAPIService = MockAPIService()
        mockStorage = MockPersistentStorage()
        mockCacheSettings = MockETagStore()

        let deps = FPLDataServiceDependencies(
            apiService: mockAPIService,
            storage: mockStorage,
            cacheSettings: mockCacheSettings
        )
        sut = FPLDataService(dependencies: deps)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockAPIService = nil
        mockStorage = nil
        mockCacheSettings = nil
        try super.tearDownWithError()
    }

    // MARK: ETag & Cache Handling Tests
    func testFetchAndPersistPassesExistingEtagToAPI() async throws {
        mockCacheSettings.saveETag("\"etag-abc-123\"")
        let team = FPLTeam(id: 1, name: "Arsenal", shortName: "ARS")
        let player = FPLPlayer(id: 10, firstName: "Bukayo", secondName: "Saka", webName: "Saka", team: 1, elementType: .midfielder, nowCost: 100, totalPoints: 150, status: .available)
        let dummyResponse = FPLBootstrapResponse(teams: [team], elements: [player])
        mockAPIService.result = .success((response: dummyResponse, newEtag: "\"etag-xyz-789\""))

        try await sut.fetchAndPersist()

        XCTAssertTrue(mockAPIService.fetchBootstrapDataCalled)
        XCTAssertEqual(mockAPIService.capturedEtag, "\"etag-abc-123\"")
        XCTAssertEqual(mockCacheSettings.storedEtag, "\"etag-xyz-789\"")
    }

    func testFetchAndPersistWhenResponseIsNilThrowsNotModified() async {
        mockCacheSettings.saveETag("\"etag-current\"")
        mockAPIService.result = .success((response: nil, newEtag: "\"etag-current\""))

        do {
            try await sut.fetchAndPersist()
            XCTFail("Expected NetworkCallError.notModified to be thrown")
        } catch let error as NetworkCallError {
            XCTAssertEqual(error, .notModified)
        } catch {
            XCTFail("Expected NetworkCallError.notModified but got \(error)")
        }
    }

    func testFetchAndPersistWhenAPIFailsPropagatesNetworkError() async {
        mockAPIService.result = .failure(NetworkCallError.noNetworkConnection)

        do {
            try await sut.fetchAndPersist()
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkCallError {
            XCTAssertEqual(error, .noNetworkConnection)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
