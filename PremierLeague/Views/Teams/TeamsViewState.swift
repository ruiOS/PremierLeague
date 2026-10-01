//
//  TeamsViewState.swift
//  main
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import Foundation

enum TeamsViewState: Equatable {
    case loading
    case loaded
    case failed(NetworkCallError)
}

enum TeamsLoadTrigger {
    case pullToRefresh
    case standard
}
