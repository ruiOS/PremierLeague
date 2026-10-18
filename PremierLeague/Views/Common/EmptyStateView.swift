//
//  EmptyStateView.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 30/09/26.
//

import SwiftUI

// MARK: - Empty State View
struct EmptyStateView: View {

    // MARK: Properties
    let icon: String
    let title: String
    let message: String
    var showRetry: Bool = false
    var onRetry: (() -> Void)? = nil

    // MARK: Body
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 52, weight: .light))
                .foregroundColor(Color(uiColor: .tertiaryLabel))
                .frame(width: 72, height: 72)
                .padding(.bottom, 8)

            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(uiColor: .secondaryLabel))
                .multilineTextAlignment(.center)

            Text(message)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color(uiColor: .tertiaryLabel))
                .multilineTextAlignment(.center)
                .padding(.bottom, showRetry ? 8 : 0)

            if showRetry {
                Button {
                    onRetry?()
                } label: {
                    Text("Try Again")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color(red: 0.24, green: 0.0, blue: 0.54))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView(
        icon: "wifi.slash",
        title: "Unable to Load",
        message: "No network connection. Showing cached data.",
        showRetry: true
    )
}
