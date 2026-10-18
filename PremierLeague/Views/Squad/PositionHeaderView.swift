//
//  PositionHeaderView.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 30/09/26.
//

import SwiftUI

// MARK: - Position Section Header View
struct PositionHeaderView: View {

    let title: String
    let count: Int

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Text(title.uppercased())
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundColor(Color(uiColor: .secondaryLabel))

                Text("(\(count))")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(uiColor: .tertiaryLabel))

                Spacer()
            }
            .frame(height: 38)
            .padding(.horizontal, 16)

            Divider()
                .padding(.horizontal, 16)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

#Preview {
    PositionHeaderView(title: "Defenders", count: 8)
}
