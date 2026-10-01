//
//  MockFPLDataService.swift
//  main
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

@testable import PremierLeague

final class MockFPLDataService: FPLDataServicable {
    var storedDataStatusReturnValue: CacheState = .empty
    private(set) var storedDataStatusCalled = false
    private(set) var storedDataStatusCalledCount = 0

    var fetchAndPersistResult: Result<Void, Error> = .success(())
    private(set) var fetchAndPersistCalled = false
    private(set) var fetchAndPersistCalledCount = 0

    private(set) var clearAllDataCalled = false
    private(set) var clearAllDataCalledCount = 0

    func storedDataStatus() -> CacheState {
        storedDataStatusCalled = true
        storedDataStatusCalledCount += 1
        return storedDataStatusReturnValue
    }

    func fetchAndPersist() async throws {
        fetchAndPersistCalled = true
        fetchAndPersistCalledCount += 1
        switch fetchAndPersistResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }

    func clearAllData() {
        clearAllDataCalled = true
        clearAllDataCalledCount += 1
    }
}
