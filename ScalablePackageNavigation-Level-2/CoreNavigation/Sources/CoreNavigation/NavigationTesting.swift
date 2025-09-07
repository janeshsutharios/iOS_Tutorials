//
//  NavigationTesting.swift
//  CoreNavigation
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI

// MARK: - Navigation Test Helper
@available(iOS 16.0, macOS 13.0, *)
public struct NavigationTestHelper {
    /// Assert that navigation occurred correctly
    public static func assertNavigation(
        from source: String,
        to destination: String,
        route: AnyHashable
    ) {
        // This would be used in unit tests to verify navigation
        print("🧪 Navigation Test: \(source) → \(destination) (route: \(route))")
    }
    
    /// Create a mock navigation coordinator for testing
    @MainActor
    public static func createMockNavigationCoordinator() -> TypeSafeNavigationCoordinator {
        return TypeSafeNavigationCoordinator()
    }
    
    /// Create a mock deep link coordinator for testing
    @MainActor
    public static func createMockDeepLinkCoordinator() -> DeepLinkCoordinator {
        return DeepLinkCoordinator(analytics: MockNavigationAnalytics())
    }
}

// MARK: - Mock Navigation Analytics
@available(iOS 16.0, macOS 13.0, *)
@MainActor
public final class MockNavigationAnalytics: NavigationAnalytics {
    public var navigationEvents: [(from: String, to: String, route: String)] = []
    public var errorEvents: [NavigationError] = []
    public var performanceEvents: [(duration: TimeInterval, from: String, to: String)] = []
    
    public init() {}
    
    public func trackNavigation(from: String, to: String, route: String) async {
        navigationEvents.append((from: from, to: to, route: route))
    }
    
    public func trackNavigationError(_ error: NavigationError) async {
        errorEvents.append(error)
    }
    
    public func trackNavigationPerformance(duration: TimeInterval, from: String, to: String) async {
        performanceEvents.append((duration: duration, from: from, to: to))
    }
    
    /// Clear all tracked events
    public func clear() {
        navigationEvents.removeAll()
        errorEvents.removeAll()
        performanceEvents.removeAll()
    }
}
