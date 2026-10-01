//
//  FPLDataServiceDependencies.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import CoreData

// MARK: - FPLDataServiceDependable
protocol FPLDataServiceDependable {
    var apiService: FPLAPIServicable { get }
    var storage: PersistentStoragable { get }
    var cacheSettings: ETagStore { get }
}

// MARK: - FPLDataServiceDependencies
struct FPLDataServiceDependencies: FPLDataServiceDependable {
    let apiService: FPLAPIServicable
    let storage: PersistentStoragable
    let cacheSettings: ETagStore

    init(
        apiService: FPLAPIServicable = FPLAPIService(),
        storage: PersistentStoragable = PersistentStorage.shared,
        cacheSettings: ETagStore = UserDefaultsETagStore()
    ) {
        self.apiService = apiService
        self.storage = storage
        self.cacheSettings = cacheSettings
    }
}
