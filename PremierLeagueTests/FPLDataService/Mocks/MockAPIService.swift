//
//  MockAPIService.swift
//  main
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

@testable import PremierLeague

final class MockAPIService: FPLAPIServicable {
    var result: Result<(response: FPLBootstrapResponse?, newEtag: String?), Error> = .success((nil, nil))
    private(set) var fetchBootstrapDataCalled = false
    private(set) var capturedEtag: String?

    func fetchBootstrapData(etag: String?) async throws -> (response: FPLBootstrapResponse?, newEtag: String?) {
        fetchBootstrapDataCalled = true
        capturedEtag = etag
        switch result {
        case .success(let val):
            return val
        case .failure(let error):
            throw error
        }
    }
}
