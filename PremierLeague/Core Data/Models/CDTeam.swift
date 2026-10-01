//
//  CDTeam.swift
//  main
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import CoreData

@objc(CDTeam)
public class CDTeam: NSManagedObject, Identifiable {

    static let entityName = "CDTeam"

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var playerCount: Int32
    @NSManaged public var shortName: String?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDTeam> {
        return NSFetchRequest<CDTeam>(entityName: CDTeam.entityName)
    }
}

extension CDTeam: EntityIdentifiable {

    func convertToFPLTeam() -> FPLTeam {
        var team = FPLTeam(
            id: Int(self.id),
            name: self.name ?? "",
            shortName: self.shortName ?? ""
        )
        team.computedPlayerCount = Int(self.playerCount)
        return team
    }
    
    func bind(team: FPLTeam, playerCount: Int) {
        self.id = Int32(team.id)
        self.name = team.name
        self.shortName = team.shortName
        self.playerCount = Int32(playerCount)
    }
}
