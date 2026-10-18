//
//  PlayerCell.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 30/09/26.
//

import SwiftUI

// MARK: - Pill Label
struct PillLabel: View {

    let text: String
    let position: PlayerPosition?

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(position?.badgeForegroundColor ?? Color(uiColor: .secondaryLabel))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(position?.badgeColor ?? Color(uiColor: .systemGray).opacity(0.2))
            .cornerRadius(4)
    }
}

// MARK: - Player Cell
struct PlayerCell: View {

    let player: FPLPlayer
    let positionShortName: String

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(player.webName)
                    .font(.headline)
                    .foregroundColor(Color(uiColor: .label))

                HStack(spacing: 8) {
                    Circle()
                        .fill(player.status.dotColor)
                        .frame(width: 10, height: 10)

                    PillLabel(text: positionShortName, position: player.elementType)

                    Text(player.formattedPrice)
                        .font(.subheadline)
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 0) {
                Text("\(player.totalPoints)")
                    .font(.system(size: 16, weight: .bold).monospacedDigit())
                    .foregroundColor(Color(uiColor: .label))

                Text("pts")
                    .font(.caption2)
                    .foregroundColor(Color(uiColor: .tertiaryLabel))
            }
            .frame(minWidth: 44, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    PlayerCell(
        player: FPLPlayer(
            id: 1,
            firstName: "Bukayo",
            secondName: "Saka",
            webName: "Saka",
            team: 1,
            elementType: .midfielder,
            nowCost: 100,
            totalPoints: 185,
            status: .available
        ),
        positionShortName: "MID"
    )
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
