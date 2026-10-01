//
//  PlayerStatus.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import Foundation

nonisolated public enum PlayerStatus: String, Codable, Sendable, CaseIterable {
    case available = "a"
    case doubtful = "d"
    case injured = "i"
    case suspended = "s"
    case unavailable = "u"
    case unknown

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = PlayerStatus(rawValue: raw) ?? .unknown
    }

    public init(rawValueOrUnknown rawValue: String?) {
        guard let rawValue = rawValue else {
            self = .unknown
            return
        }
        self = PlayerStatus(rawValue: rawValue) ?? .unknown
    }

    public var displayName: String {
        switch self {
        case .available:
            return "Available"
        case .doubtful:
            return "Doubtful"
        case .injured:
            return "Injured"
        case .suspended:
            return "Suspended"
        case .unavailable:
            return "Unavailable"
        case .unknown:
            return "Unknown"
        }
    }
}
