//
//  PlayerPosition.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import Foundation

nonisolated public enum PlayerPosition: Int, CaseIterable, Codable, Sendable, Comparable {
    case goalkeeper = 1
    case defender = 2
    case midfielder = 3
    case forward = 4
    case unknown = 0

    public static func < (lhs: PlayerPosition, rhs: PlayerPosition) -> Bool {
        // Natural football ordering: GKP (1) < DEF (2) < MID (3) < FWD (4) < Unknown
        if lhs == .unknown { return false }
        if rhs == .unknown { return true }
        return lhs.rawValue < rhs.rawValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(Int.self)
        self = PlayerPosition(rawValue: raw) ?? .unknown
    }

    public init(rawValueOrUnknown rawValue: Int?) {
        guard let rawValue = rawValue else {
            self = .unknown
            return
        }
        self = PlayerPosition(rawValue: rawValue) ?? .unknown
    }

    public var pluralName: String {
        switch self {
        case .goalkeeper: return "Goalkeepers"
        case .defender: return "Defenders"
        case .midfielder: return "Midfielders"
        case .forward: return "Forwards"
        case .unknown: return "Unknown"
        }
    }

    public var shortName: String {
        switch self {
        case .goalkeeper: return "GKP"
        case .defender: return "DEF"
        case .midfielder: return "MID"
        case .forward: return "FWD"
        case .unknown: return "-"
        }
    }
}
