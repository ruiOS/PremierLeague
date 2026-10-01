//
//  CacheState.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import Foundation

nonisolated enum CacheState: Sendable {
    case empty
    case available

    var hasData: Bool {
        self == .available
    }

    var isEmpty: Bool {
        self == .empty
    }
}
