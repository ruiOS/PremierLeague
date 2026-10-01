//
//  MockKeyValueStore.swift
//  main
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

@testable import PremierLeague

final class MockKeyValueStore: KeyValueStore {
    var storage: [String: String] = [:]

    func string(forKey key: String) -> String? {
        storage[key]
    }

    func set(_ value: String?, forKey key: String) {
        storage[key] = value
    }

    func remove(forKey key: String) {
        storage.removeValue(forKey: key)
    }
}
