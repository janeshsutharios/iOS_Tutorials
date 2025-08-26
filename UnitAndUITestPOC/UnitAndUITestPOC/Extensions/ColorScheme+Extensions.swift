//
//  ColorScheme+Extensions.swift
//  UnitAndUITestPOC
//
//  Created by Janesh Suthar on 25/08/25.
//

import SwiftUI

extension ColorScheme {
    
    // MARK: - Background Colors
    
    var primaryBackground: Color {
        switch self {
        case .dark:
            return Color.black
        case .light:
            return Color.white
        @unknown default:
            return Color.white
        }
    }
    
    var secondaryBackground: Color {
        switch self {
        case .dark:
            return Color.black.opacity(0.3)
        case .light:
            return Color.gray.opacity(0.1)
        @unknown default:
            return Color.gray.opacity(0.1)
        }
    }
    
    var cardBackground: Color {
        switch self {
        case .dark:
            return Color.black.opacity(0.3)
        case .light:
            return Color.white
        @unknown default:
            return Color.white
        }
    }
    
    // MARK: - Text Colors
    
    var primaryText: Color {
        switch self {
        case .dark:
            return Color.white
        case .light:
            return Color.black
        @unknown default:
            return Color.black
        }
    }
    
    var secondaryText: Color {
        switch self {
        case .dark:
            return Color.white.opacity(0.8)
        case .light:
            return Color.black.opacity(0.6)
        @unknown default:
            return Color.black.opacity(0.6)
        }
    }
    
    var tertiaryText: Color {
        switch self {
        case .dark:
            return Color.white.opacity(0.6)
        case .light:
            return Color.black.opacity(0.4)
        @unknown default:
            return Color.black.opacity(0.4)
        }
    }
    
    // MARK: - Accent Colors
    
    var primaryAccent: Color {
        switch self {
        case .dark:
            return Color.blue.opacity(0.8)
        case .light:
            return Color.blue
        @unknown default:
            return Color.blue
        }
    }
    
    var secondaryAccent: Color {
        switch self {
        case .dark:
            return Color.purple.opacity(0.8)
        case .light:
            return Color.purple
        @unknown default:
            return Color.purple
        }
    }
    
    // MARK: - Status Colors
    
    var successColor: Color {
        switch self {
        case .dark:
            return Color.green.opacity(0.8)
        case .light:
            return Color.green
        @unknown default:
            return Color.green
        }
    }
    
    var errorColor: Color {
        switch self {
        case .dark:
            return Color.red.opacity(0.8)
        case .light:
            return Color.red
        @unknown default:
            return Color.red
        }
    }
    
    var warningColor: Color {
        switch self {
        case .dark:
            return Color.orange.opacity(0.8)
        case .light:
            return Color.orange
        @unknown default:
            return Color.orange
        }
    }
    
    // MARK: - Shadow Colors
    
    var shadowColor: Color {
        switch self {
        case .dark:
            return Color.white.opacity(0.1)
        case .light:
            return Color.black.opacity(0.1)
        @unknown default:
            return Color.black.opacity(0.1)
        }
    }
    
    // MARK: - Gradient Colors
    
    var primaryGradientStart: Color {
        switch self {
        case .dark:
            return Color.blue.opacity(0.2)
        case .light:
            return Color.blue.opacity(0.6)
        @unknown default:
            return Color.blue.opacity(0.6)
        }
    }
    
    var primaryGradientEnd: Color {
        switch self {
        case .dark:
            return Color.purple.opacity(0.2)
        case .light:
            return Color.purple.opacity(0.6)
        @unknown default:
            return Color.purple.opacity(0.6)
        }
    }
    
    // MARK: - Loading Colors
    
    var loadingBackground: Color {
        switch self {
        case .dark:
            return Color.gray.opacity(0.2)
        case .light:
            return Color.gray.opacity(0.3)
        @unknown default:
            return Color.gray.opacity(0.3)
        }
    }
    
    var loadingTint: Color {
        switch self {
        case .dark:
            return Color.white
        case .light:
            return Color.blue
        @unknown default:
            return Color.blue
        }
    }
}

// MARK: - View Extensions

extension View {
    func adaptiveBackground(_ colorScheme: ColorScheme) -> some View {
        self.background(colorScheme.secondaryBackground)
    }
    
    func adaptiveCardBackground(_ colorScheme: ColorScheme) -> some View {
        self.background(colorScheme.cardBackground)
    }
    
    func adaptiveShadow(_ colorScheme: ColorScheme, radius: CGFloat = 8, x: CGFloat = 0, y: CGFloat = 4) -> some View {
        self.shadow(color: colorScheme.shadowColor, radius: radius, x: x, y: y)
    }
}
