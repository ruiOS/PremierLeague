//
//  FPLModelsTests.swift
//  PremierLeagueTests
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import XCTest
@testable import PremierLeague

final class FPLModelsTests: XCTestCase {

    func testPlayerFormattedPriceCalculatesCorrectly() {
        let player1 = FPLPlayer(id: 1, firstName: "Erling", secondName: "Haaland", webName: "Haaland", team: 1, elementType: .forward, nowCost: 153, totalPoints: 100, status: .available)
        let player2 = FPLPlayer(id: 2, firstName: "Cole", secondName: "Palmer", webName: "Palmer", team: 2, elementType: .midfielder, nowCost: 105, totalPoints: 95, status: .available)
        let player3 = FPLPlayer(id: 3, firstName: "Cheap", secondName: "Player", webName: "Cheap", team: 3, elementType: .defender, nowCost: 40, totalPoints: 20, status: .available)

        XCTAssertEqual(player1.formattedPrice, "£15.3m")
        XCTAssertEqual(player2.formattedPrice, "£10.5m")
        XCTAssertEqual(player3.formattedPrice, "£4.0m")
    }

    func testPlayerStatusEnumProperties() {
        XCTAssertEqual(PlayerStatus.available.displayName, "Available")
        XCTAssertEqual(PlayerStatus.doubtful.displayName, "Doubtful")
        XCTAssertEqual(PlayerStatus.injured.displayName, "Injured")
        XCTAssertEqual(PlayerStatus.suspended.displayName, "Suspended")
        XCTAssertEqual(PlayerStatus.unavailable.displayName, "Unavailable")
        XCTAssertEqual(PlayerStatus.unknown.displayName, "Unknown")

        XCTAssertEqual(PlayerStatus(rawValueOrUnknown: "a"), .available)
        XCTAssertEqual(PlayerStatus(rawValueOrUnknown: "d"), .doubtful)
        XCTAssertEqual(PlayerStatus(rawValueOrUnknown: "i"), .injured)
        XCTAssertEqual(PlayerStatus(rawValueOrUnknown: "s"), .suspended)
        XCTAssertEqual(PlayerStatus(rawValueOrUnknown: "u"), .unavailable)
        XCTAssertEqual(PlayerStatus(rawValueOrUnknown: "xyz"), .unknown)
        XCTAssertEqual(PlayerStatus(rawValueOrUnknown: nil), .unknown)
    }

    func testPlayerPositionEnumProperties() {
        XCTAssertEqual(PlayerPosition.goalkeeper.pluralName, "Goalkeepers")
        XCTAssertEqual(PlayerPosition.goalkeeper.shortName, "GKP")

        XCTAssertEqual(PlayerPosition.defender.pluralName, "Defenders")
        XCTAssertEqual(PlayerPosition.defender.shortName, "DEF")

        XCTAssertEqual(PlayerPosition.midfielder.pluralName, "Midfielders")
        XCTAssertEqual(PlayerPosition.midfielder.shortName, "MID")

        XCTAssertEqual(PlayerPosition.forward.pluralName, "Forwards")
        XCTAssertEqual(PlayerPosition.forward.shortName, "FWD")

        XCTAssertEqual(PlayerPosition.unknown.pluralName, "Unknown")
        XCTAssertEqual(PlayerPosition.unknown.shortName, "-")

        XCTAssertEqual(PlayerPosition(rawValueOrUnknown: 1), .goalkeeper)
        XCTAssertEqual(PlayerPosition(rawValueOrUnknown: 2), .defender)
        XCTAssertEqual(PlayerPosition(rawValueOrUnknown: 3), .midfielder)
        XCTAssertEqual(PlayerPosition(rawValueOrUnknown: 4), .forward)
        XCTAssertEqual(PlayerPosition(rawValueOrUnknown: 99), .unknown)
        XCTAssertEqual(PlayerPosition(rawValueOrUnknown: nil), .unknown)
    }

    func testCacheStateProperties() {
        XCTAssertTrue(CacheState.available.hasData)
        XCTAssertFalse(CacheState.available.isEmpty)

        XCTAssertFalse(CacheState.empty.hasData)
        XCTAssertTrue(CacheState.empty.isEmpty)
    }

    func testNetworkCallErrorLocalizedDescription() {
        XCTAssertEqual(NetworkCallError.urlCantBeGenerated.localizedDescription, "Unable to construct a valid URL.")
        XCTAssertEqual(NetworkCallError.noDataPresent.localizedDescription, "No data was returned by the server.")
        XCTAssertEqual(NetworkCallError.noNetworkConnection.localizedDescription, "No network connection. Showing cached data.")
        XCTAssertEqual(NetworkCallError.notModified.localizedDescription, "Data is up to date.")
        XCTAssertEqual(NetworkCallError.serverSideError("Bad Gateway").localizedDescription, "Server error: Bad Gateway")
        XCTAssertEqual(NetworkCallError.dataParseError("Missing key").localizedDescription, "Failed to decode response: Missing key")
    }

    func testFPLBootstrapResponseDecoding() throws {
        let json = """
        {
            "teams": [
                {
                    "id": 1,
                    "name": "Arsenal",
                    "short_name": "ARS"
                }
            ],
            "elements": [
                {
                    "id": 10,
                    "first_name": "Bukayo",
                    "second_name": "Saka",
                    "web_name": "Saka",
                    "team": 1,
                    "element_type": 3,
                    "now_cost": 100,
                    "total_points": 180,
                    "status": "a"
                }
            ]
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(FPLBootstrapResponse.self, from: json)

        XCTAssertEqual(response.teams.count, 1)
        XCTAssertEqual(response.teams.first?.name, "Arsenal")
        XCTAssertEqual(response.teams.first?.shortName, "ARS")

        XCTAssertEqual(response.elements.count, 1)
        XCTAssertEqual(response.elements.first?.webName, "Saka")
        XCTAssertEqual(response.elements.first?.formattedPrice, "£10.0m")
    }

    func testRealAPIBootstrapJSONDecodingAndTransformation() throws {
        let testBundle = Bundle(for: type(of: self))
        let jsonURL = testBundle.url(forResource: "sample_home_response", withExtension: "json")
            ?? URL(fileURLWithPath: #file)
                .deletingLastPathComponent()
                .appendingPathComponent("sample_home_response.json")

        let data = try Data(contentsOf: jsonURL)

        let decodedResponse = try JSONDecoder().decode(FPLBootstrapResponse.self, from: data)

        XCTAssertEqual(decodedResponse.teams.count, 3)
        XCTAssertEqual(decodedResponse.elements.count, 6)

        let arsenal = decodedResponse.teams[0]
        XCTAssertEqual(arsenal.id, 1)
        XCTAssertEqual(arsenal.name, "Arsenal")
        XCTAssertEqual(arsenal.shortName, "ARS")

        let astonVilla = decodedResponse.teams[1]
        XCTAssertEqual(astonVilla.id, 2)
        XCTAssertEqual(astonVilla.name, "Aston Villa")
        XCTAssertEqual(astonVilla.shortName, "AVL")

        let raya = decodedResponse.elements[0]
        XCTAssertEqual(raya.id, 1)
        XCTAssertEqual(raya.webName, "Raya")
        XCTAssertEqual(raya.team, 1)
        XCTAssertEqual(raya.elementType, .goalkeeper)
        XCTAssertEqual(raya.nowCost, 61)
        XCTAssertEqual(raya.formattedPrice, "£6.1m")
        XCTAssertEqual(raya.status, .available)

        let gabriel = decodedResponse.elements[3]
        XCTAssertEqual(gabriel.id, 4)
        XCTAssertEqual(gabriel.webName, "Gabriel")
        XCTAssertEqual(gabriel.nowCost, 80)
        XCTAssertEqual(gabriel.formattedPrice, "£8.0m")
        XCTAssertEqual(gabriel.elementType, .defender)

        let saliba = decodedResponse.elements[5]
        XCTAssertEqual(saliba.id, 6)
        XCTAssertEqual(saliba.webName, "Saliba")
        XCTAssertEqual(saliba.status, .injured)
        XCTAssertEqual(saliba.formattedPrice, "£5.9m")
    }
}
