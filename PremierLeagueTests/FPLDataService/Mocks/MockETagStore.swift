//
//  MockETagStore.swift
//  main
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

@testable import PremierLeague

final class MockETagStore: ETagStore {
    var storedEtag: String?
    private(set) var saveETagCalled = false
    private(set) var clearETagCalled = false

    func getETag() -> String? {
        storedEtag
    }

    func saveETag(_ etag: String) {
        saveETagCalled = true
        storedEtag = etag
    }

    func clearETag() {
        clearETagCalled = true
        storedEtag = nil
    }
}
