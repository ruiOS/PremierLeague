//
//  AppTheme.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 01/10/26.
//

import UIKit

// MARK: - App Theme
enum AppTheme {

    // MARK: - Team Color Palette
    enum Team {
        struct Colors {
            let background: UIColor
            let text: UIColor
        }

        private static let palette: [UIColor] = [
            UIColor(red: 0.84, green: 0.07, blue: 0.07, alpha: 1),
            UIColor(red: 0.49, green: 0.05, blue: 0.36, alpha: 1),
            UIColor(red: 0.07, green: 0.32, blue: 0.67, alpha: 1),
            UIColor(red: 0.02, green: 0.52, blue: 0.35, alpha: 1),
            UIColor(red: 0.97, green: 0.60, blue: 0.11, alpha: 1),
            UIColor(red: 0.11, green: 0.18, blue: 0.51, alpha: 1),
            UIColor(red: 0.98, green: 0.25, blue: 0.13, alpha: 1),
            UIColor(red: 0.38, green: 0.67, blue: 0.27, alpha: 1),
            UIColor(red: 0.03, green: 0.32, blue: 0.68, alpha: 1),
            UIColor(red: 0.86, green: 0.07, blue: 0.23, alpha: 1),
            UIColor(red: 0.96, green: 0.79, blue: 0.02, alpha: 1),
            UIColor(red: 0.53, green: 0.07, blue: 0.15, alpha: 1),
            UIColor(red: 0.11, green: 0.42, blue: 0.68, alpha: 1),
            UIColor(red: 0.02, green: 0.35, blue: 0.55, alpha: 1),
            UIColor(red: 0.93, green: 0.31, blue: 0.08, alpha: 1),
            UIColor(red: 0.08, green: 0.14, blue: 0.45, alpha: 1),
        ]

        static func color(for teamId: Int) -> Colors {
            let index = abs(teamId - 1) % palette.count
            let bg = palette[index]
            var hue: CGFloat = 0, sat: CGFloat = 0, bri: CGFloat = 0, alpha: CGFloat = 0
            bg.getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)
            let textColor: UIColor = bri > 0.8 ? UIColor(white: 0.1, alpha: 1) : .white
            return Colors(background: bg, text: textColor)
        }
    }
}

typealias TeamColorPalette = AppTheme.Team

// MARK: - PlayerPosition Presentation Styling
extension PlayerPosition {

    var badgeBackgroundColor: UIColor {
        switch self {
        case .goalkeeper:
            return UIColor(red: 0.98, green: 0.76, blue: 0.18, alpha: 0.20)
        case .defender:
            return UIColor(red: 0.2, green: 0.78, blue: 0.35, alpha: 0.20)
        case .midfielder:
            return UIColor(red: 0.20, green: 0.50, blue: 0.95, alpha: 0.20)
        case .forward:
            return UIColor(red: 0.93, green: 0.26, blue: 0.21, alpha: 0.20)
        case .unknown:
            return UIColor.systemGray.withAlphaComponent(0.20)
        }
    }

    var badgeTextColor: UIColor {
        switch self {
        case .goalkeeper:
            return UIColor(red: 0.75, green: 0.52, blue: 0.0, alpha: 1)
        case .defender:
            return UIColor(red: 0.09, green: 0.56, blue: 0.24, alpha: 1)
        case .midfielder:
            return UIColor(red: 0.10, green: 0.34, blue: 0.80, alpha: 1)
        case .forward:
            return UIColor(red: 0.73, green: 0.10, blue: 0.08, alpha: 1)
        case .unknown:
            return .secondaryLabel
        }
    }
}

// MARK: - PlayerStatus Presentation Styling
extension PlayerStatus {

    var statusDotColor: UIColor {
        switch self {
        case .available:
            return UIColor(red: 0.2, green: 0.78, blue: 0.35, alpha: 1) // Green
        case .doubtful:
            return UIColor(red: 1, green: 0.72, blue: 0.1, alpha: 1)    // Amber
        case .injured:
            return UIColor(red: 0.93, green: 0.26, blue: 0.21, alpha: 1) // Red
        case .suspended, .unavailable, .unknown:
            return .systemGray
        }
    }
}
