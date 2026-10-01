//
//  CDPlayer.swift
//  main
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import CoreData

@objc(CDPlayer)
public class CDPlayer: NSManagedObject, Identifiable {

    public static let entityName: String = "CDPlayer"

    @NSManaged public var elementType: Int32
    @NSManaged public var firstName: String?
    @NSManaged public var id: Int32
    @NSManaged public var nowCost: Int32
    @NSManaged public var secondName: String?
    @NSManaged public var status: String?
    @NSManaged public var teamId: Int32
    @NSManaged public var totalPoints: Int32
    @NSManaged public var webName: String?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDPlayer> {
        return NSFetchRequest<CDPlayer>(entityName: CDPlayer.entityName)
    }
}

extension CDPlayer: EntityIdentifiable {

    func convertToFPLPlayer() -> FPLPlayer {
        return FPLPlayer(
            id: Int(self.id),
            firstName: self.firstName ?? "",
            secondName: self.secondName ?? "",
            webName: self.webName ?? "",
            team: Int(self.teamId),
            elementType: PlayerPosition(rawValueOrUnknown: Int(self.elementType)),
            nowCost: Int(self.nowCost),
            totalPoints: Int(self.totalPoints),
            status: PlayerStatus(rawValueOrUnknown: self.status)
        )
    }

    func bind(player: FPLPlayer) {
        self.elementType = Int32(player.elementType.rawValue)
        self.firstName = player.firstName
        self.id = Int32(player.id)
        self.nowCost = Int32(player.nowCost)
        self.secondName = player.secondName
        self.status = player.status.rawValue
        self.teamId = Int32(player.team)
        self.totalPoints = Int32(player.totalPoints)
        self.webName = player.webName
    }
}
