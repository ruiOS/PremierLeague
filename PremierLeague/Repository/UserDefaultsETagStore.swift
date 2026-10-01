//
//  UserDefaultsETagStore.swift
//  main
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import Foundation

// MARK: - ETagStore
protocol ETagStore {
    func getETag() -> String?
    func saveETag(_ etag: String)
    func clearETag()
}

// MARK: - UserDefaultsETagStore
struct UserDefaultsETagStore: ETagStore {
    private let storage: KeyValueStore
    private let etagKey = "FPLBootstrapEtag"
    
    init(storage: KeyValueStore = UserDefaultsStore.shared) {
        self.storage = storage
    }

    func getETag() -> String? {
        storage.string(forKey: etagKey)
    }
    
    func saveETag(_ etag: String) {
        storage.set(etag, forKey: etagKey)
    }
    
    func clearETag() {
        storage.remove(forKey: etagKey)
    }
}
