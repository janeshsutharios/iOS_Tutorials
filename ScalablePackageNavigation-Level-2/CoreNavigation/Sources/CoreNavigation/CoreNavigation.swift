//
//  CoreNavigation.swift
//  CoreNavigation
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI

// MARK: - Core Navigation Module
// This module provides the foundational navigation infrastructure for the scalable iOS app architecture.

public struct CoreNavigation {
    public static let version = "3.0.0"
    
    public init() {}
}

// MARK: - App Features
/// Enumeration of all app features for type-safe navigation

public enum AppFeature: String, CaseIterable, Sendable {
    case auth = "auth"
    case dashboard = "dashboard"
    case messages = "messages"
    case profile = "profile"
}

// MARK: - Navigation Environment Protocol
/// Protocol for environment-based navigation that allows cross-package navigation
/// without direct dependencies between packages

@available(iOS 13.0, macOS 10.15, *)
@MainActor
public protocol NavigationEnvironment: ObservableObject, Sendable {
    /// Navigate to a specific route in the current navigation context
    func navigate<Route: Hashable & Sendable>(to route: Route)
    
    /// Navigate back in the current navigation stack
    func navigateBack()
    
    /// Navigate to the root of the current navigation stack
    func navigateToRoot()
    
    /// Navigate to a different feature using type-safe feature enum
    func navigateToFeature<Route: Hashable & Sendable>(_ feature: AppFeature, route: Route)
}

// MARK: - Navigation Environment Key

@available(iOS 13.0, macOS 10.15, *)
public struct NavigationEnvironmentKey: EnvironmentKey {
    public static let defaultValue: (any NavigationEnvironment)? = nil
}


@available(iOS 13.0, macOS 10.15, *)
public extension EnvironmentValues {
    var navigationEnvironment: (any NavigationEnvironment)? {
        get { self[NavigationEnvironmentKey.self] }
        set { self[NavigationEnvironmentKey.self] = newValue }
    }
}
