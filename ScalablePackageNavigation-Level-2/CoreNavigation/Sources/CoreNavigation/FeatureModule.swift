//
//  FeatureModule.swift
//  CoreNavigation
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI

// MARK: - Feature Module Protocol
/// Protocol for auto-discovering feature modules
@available(iOS 16.0, macOS 13.0, *)
public protocol FeatureModule {
    /// The feature this module represents
    static var feature: AppFeature { get }
    
    /// Register this feature with the navigation coordinator
    static func register(with coordinator: NavigationCoordinator)
    
    /// Create the navigation container for this feature
    static func createNavigationContainer() -> AnyView
}

// MARK: - Feature Module Registry
/// Central registry for all feature modules
@available(iOS 16.0, macOS 13.0, *)
@MainActor
public final class FeatureModuleRegistry {
    private static var modules: [AppFeature: any FeatureModule.Type] = [:]
    
    /// Register a feature module
    public static func register(_ module: any FeatureModule.Type) {
        modules[module.feature] = module
    }
    
    /// Get all registered modules
    public static var allModules: [any FeatureModule.Type] {
        return Array(modules.values)
    }
    
    /// Get a specific module by feature
    public static func module(for feature: AppFeature) -> (any FeatureModule.Type)? {
        return modules[feature]
    }
    
    /// Check if a feature is registered
    public static func isRegistered(_ feature: AppFeature) -> Bool {
        return modules[feature] != nil
    }
    
    /// Clear all registrations (useful for testing)
    public static func clear() {
        modules.removeAll()
    }
}

// MARK: - Auto-Registration
/// Automatically register feature modules using static initialization
@available(iOS 16.0, macOS 13.0, *)
public struct FeatureModuleAutoRegistration {
    public static func registerAll() {
        // This will be called automatically when the app starts
        // Each feature module should register itself in its static initializer
    }
}
