//
//  FPLModels.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 30/09/26.
//

import Foundation

// MARK: - FPL Bootstrap Response
nonisolated struct FPLBootstrapResponse: Codable, Sendable {
    let teams: [FPLTeam]
    let elements: [FPLPlayer]

    enum CodingKeys: String, CodingKey {
        case teams
        case elements
    }

    init(teams: [FPLTeam], elements: [FPLPlayer]) {
        self.teams = teams
        self.elements = elements
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        teams = try container.decode([FPLTeam].self, forKey: .teams)
        elements = try container.decode([FPLPlayer].self, forKey: .elements)
    }
}

// MARK: - Team
nonisolated struct FPLTeam: Codable, Equatable, Sendable {
    let id: Int
    let name: String
    let shortName: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case shortName = "short_name"
    }

    var computedPlayerCount: Int = 0
}

// MARK: - Player
nonisolated struct FPLPlayer: Codable, Equatable, Sendable {
    let id: Int
    let firstName: String
    let secondName: String
    let webName: String
    let team: Int
    let elementType: PlayerPosition      // position enum (1=GKP, 2=DEF, 3=MID, 4=FWD, 0=unknown)
    let nowCost: Int          // price x10 (e.g. 61 = £6.1m)
    let totalPoints: Int
    let status: PlayerStatus

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case secondName = "second_name"
        case webName = "web_name"
        case team
        case elementType = "element_type"
        case nowCost = "now_cost"
        case totalPoints = "total_points"
        case status
    }

    /// Price formatted as £X.Xm
    var formattedPrice: String {
        let value = Double(nowCost) / 10.0
        return String(format: "£%.1fm", value)
    }
}

// MARK: - Network Error
nonisolated enum NetworkCallError: Error, Equatable, Sendable {
    case urlCantBeGenerated
    case serverSideError(String)
    case noDataPresent
    case dataParseError(String)
    case noNetworkConnection
    case notModified // ETag matched, data hasn't changed

    var localizedDescription: String {
        switch self {
        case .urlCantBeGenerated:
            return "Unable to construct a valid URL."
        case .serverSideError(let msg):
            return "Server error: \(msg)"
        case .noDataPresent:
            return "No data was returned by the server."
        case .dataParseError(let msg):
            return "Failed to decode response: \(msg)"
        case .noNetworkConnection:
            return "No network connection. Showing cached data."
        case .notModified:
            return "Data is up to date."
        }
    }
}
