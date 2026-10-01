//
//  HTTPMethod.swift
//  NimbleTest
//
//  Created by rupesh on 24/03/22.
//

import Foundation

///Common HTTP MEthods
nonisolated enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
