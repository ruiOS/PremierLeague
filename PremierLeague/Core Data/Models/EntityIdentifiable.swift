//
//  EntityIdentifiable.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 30/09/26.
//

import CoreData

///NSManagedObject methods to access managedObject in app
protocol EntityIdentifiable: NSFetchRequestResult {
    ///entityname of the object
    static var entityName: String {get}
}
