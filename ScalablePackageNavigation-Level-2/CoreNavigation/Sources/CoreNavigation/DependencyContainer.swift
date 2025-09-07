//
//  DependencyContainer.swift
//  CoreNavigation
//
//  Created by Janesh Suthar on 06/09/25.
//

import Foundation
import SwiftUI

// MARK: - Dependency Container Protocol
/// Protocol for dependency injection container that manages all app dependencies
public protocol DependencyContainer: Sendable {
    /// Register a dependency with a specific type
    func register<T: Sendable>(_ type: T.Type, factory: @escaping @Sendable () -> T) async
    
    /// Resolve a dependency of a specific type
    func resolve<T: Sendable>(_ type: T.Type) async -> T
    
    /// Check if a dependency is registered
    func isRegistered<T>(_ type: T.Type) async -> Bool
    
    /// Register a dependency with a specific scope (transient or scoped)
    func register<T: Sendable>(_ type: T.Type, factory: @escaping @Sendable () -> T, scope: DependencyScope) async
}

// MARK: - Dependency Scope
/// Defines the lifetime of a dependency
public enum DependencyScope: Sendable {
    /// New instance created every time (default)
    case transient
    
    /// Single instance per container lifecycle
    case scoped
}

// MARK: - Dependency Registration
private struct DependencyRegistration: Sendable {
    let factory: @Sendable () -> Any
    let scope: DependencyScope
}

// MARK: - Actor-Based Dependency Container
// Using actor for Swift 6 native concurrency and thread safety
public actor DefaultDependencyContainer: DependencyContainer {
    private var registrations: [String: DependencyRegistration] = [:]
    private var scopedInstances: [String: Any] = [:]
    
    public init() {}
    
    public func register<T: Sendable>(_ type: T.Type, factory: @escaping @Sendable () -> T) async {
        await register(type, factory: factory, scope: .transient)
    }
    
    public func register<T: Sendable>(_ type: T.Type, factory: @escaping @Sendable () -> T, scope: DependencyScope) async {
        let key = String(describing: type)
        let registration = DependencyRegistration(factory: factory, scope: scope)
        registrations[key] = registration
    }
    
    public func resolve<T: Sendable>(_ type: T.Type) async -> T {
        let key = String(describing: type)
        
        // Get registration
        guard let registration = registrations[key] else {
            fatalError("Dependency of type \(type) is not registered")
        }
        
        // Handle scoped dependencies
        if registration.scope == .scoped {
            // Check if we already have a scoped instance
            if let scopedInstance = scopedInstances[key] as? T {
                return scopedInstance
            }
            
            // Create new scoped instance
            let instance = registration.factory() as! T
            
            // Store scoped instance
            scopedInstances[key] = instance
            
            return instance
        } else {
            // Transient - create new instance every time
            return registration.factory() as! T
        }
    }
    
    public func isRegistered<T>(_ type: T.Type) async -> Bool {
        let key = String(describing: type)
        return registrations[key] != nil
    }
    
    /// Clear all scoped instances (useful for testing or container reset)
    public func clearScopedInstances() {
        scopedInstances.removeAll()
    }
    
    /// Reset the entire container (useful for testing)
    public func reset() {
        registrations.removeAll()
        scopedInstances.removeAll()
    }
}

// MARK: - Dependency Container Environment Key

public struct DependencyContainerKey: EnvironmentKey {
    public static let defaultValue: DependencyContainer = DefaultDependencyContainer()
}


public extension EnvironmentValues {
    var dependencyContainer: DependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}
