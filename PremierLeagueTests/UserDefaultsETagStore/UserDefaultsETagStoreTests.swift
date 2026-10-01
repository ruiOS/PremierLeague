//
//  UserDefaultsETagStoreTests.swift
//  PremierLeagueTests
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import XCTest
@testable import PremierLeague

final class UserDefaultsETagStoreTests: XCTestCase {

    private var mockKeyValueStore: MockKeyValueStore!
    private var sut: UserDefaultsETagStore!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockKeyValueStore = MockKeyValueStore()
        sut = UserDefaultsETagStore(storage: mockKeyValueStore)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockKeyValueStore = nil
        try super.tearDownWithError()
    }

    func testGetETagReturnsNilWhenEmpty() {
        // Assert
        XCTAssertNil(sut.getETag())
    }

    func testSaveETagStoresValueInKeyValueStore() {
        // Act
        sut.saveETag("test-etag-12345")

        // Assert
        XCTAssertEqual(sut.getETag(), "test-etag-12345")
        XCTAssertEqual(mockKeyValueStore.string(forKey: "FPLBootstrapEtag"), "test-etag-12345")
    }

    func testClearETagRemovesValue() {
        // Arrange
        sut.saveETag("test-etag-12345")
        XCTAssertNotNil(sut.getETag())

        // Act
        sut.clearETag()

        // Assert
        XCTAssertNil(sut.getETag())
        XCTAssertNil(mockKeyValueStore.string(forKey: "FPLBootstrapEtag"))
    }
}
