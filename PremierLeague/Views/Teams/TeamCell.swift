//
//  TeamCell.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 30/09/26.
//

import SwiftUI

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Team Cell
struct TeamCell: View {

    let team: FPLTeam

    var body: some View {
        let colors = AppTheme.Team.color(for: team.id)

        HStack(spacing: 14) {
            // Team short name badge
            ZStack {
                Circle()
                    .fill(colors.swiftUIBackground)
                    .frame(width: 52, height: 52)

                Text(team.shortName)
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(colors.swiftUIText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            // Team info labels
            VStack(alignment: .leading, spacing: 3) {
                Text(team.name)
                    .font(.headline)
                    .foregroundColor(Color(uiColor: .label))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text("\(team.computedPlayerCount) players")
                    .font(.subheadline)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(uiColor: .tertiaryLabel))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
        .contentShape(Rectangle())
    }
}

#Preview {
    TeamCell(team: FPLTeam(id: 1, name: "Arsenal", shortName: "ARS", computedPlayerCount: 25))
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
}
