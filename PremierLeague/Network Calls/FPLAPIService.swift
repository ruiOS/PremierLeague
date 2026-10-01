//
//  FPLAPIService.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 30/09/26.
//

import Foundation

// MARK: - FPL API Service Protocol
protocol FPLAPIServicable {
    func fetchBootstrapData(etag: String?) async throws -> (response: FPLBootstrapResponse?, newEtag: String?)
}

// MARK: - Live FPL API Service

final class FPLAPIService: FPLAPIServicable {

    // MARK: Properties
    private let session: URLSession

    // MARK: Initialiser
    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: FPLAPIServicable
    func fetchBootstrapData(etag: String?) async throws -> (response: FPLBootstrapResponse?, newEtag: String?) {
        guard let url = URL(string: "https://fantasy.premierleague.com/api/bootstrap-static/") else {
            throw NetworkCallError.urlCantBeGenerated
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.timeoutInterval = 15.0

        request.setValue("PremierLeague/1.0", forHTTPHeaderField: "User-Agent")
        
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        if let etag = etag {
            request.setValue(etag, forHTTPHeaderField: "If-None-Match")
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError where urlError.code == .notConnectedToInternet
                                             || urlError.code == .networkConnectionLost {
            throw NetworkCallError.noNetworkConnection
        } catch {
            throw NetworkCallError.serverSideError(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkCallError.noDataPresent
        }

        // If the server returns 304, the data hasn't changed.
        if httpResponse.statusCode == 304 {
            return (nil, etag)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkCallError.serverSideError("HTTP \(httpResponse.statusCode)")
        }

        guard !data.isEmpty else {
            throw NetworkCallError.noDataPresent
        }

        do {
            let decoded = try await Task.detached {
                try JSONDecoder().decode(FPLBootstrapResponse.self, from: data)
            }.value
            let newEtag = httpResponse.value(forHTTPHeaderField: "Etag") ?? httpResponse.value(forHTTPHeaderField: "etag")
            return (decoded, newEtag)
        } catch {
            throw NetworkCallError.dataParseError(error.localizedDescription)
        }
    }
}
