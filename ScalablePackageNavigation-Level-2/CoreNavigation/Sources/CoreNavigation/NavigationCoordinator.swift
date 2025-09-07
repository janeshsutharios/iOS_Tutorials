//
//  NavigationCoordinator.swift
//  CoreNavigation
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI

// MARK: - Type-Safe Navigation Coordinator
/// Centralized navigation coordinator that provides type-safe cross-feature navigation

@MainActor
public final class NavigationCoordinator: ObservableObject, Sendable {
    // MARK: - Navigation Handlers
    private var navigationHandlers: [AppFeature: (AnyHashable) -> Void] = [:]
    
    public init() {}
    
    // MARK: - Public API
    /// Register a navigation handler for a specific feature
    public func registerNavigationHandler(
        for feature: AppFeature,
        handler: @escaping (AnyHashable) -> Void
    ) {
        navigationHandlers[feature] = handler
    }
    
    /// Navigate to a specific feature with a route
    public func navigateToFeature(_ feature: AppFeature, route: AnyHashable) {
        guard let handler = navigationHandlers[feature] else {
            print("⚠️ No navigation handler registered for feature: \(feature.rawValue)")
            return
        }
        handler(route)
    }
    
    /// Check if a feature has a registered navigation handler
    public func hasHandler(for feature: AppFeature) -> Bool {
        return navigationHandlers[feature] != nil
    }
}
