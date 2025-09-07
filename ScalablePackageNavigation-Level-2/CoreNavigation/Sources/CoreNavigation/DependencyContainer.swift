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
    func register<T>(_ type: T.Type, factory: @escaping @Sendable () -> T)
    
    /// Resolve a dependency of a specific type
    func resolve<T>(_ type: T.Type) -> T
    
    /// Check if a dependency is registered
    func isRegistered<T>(_ type: T.Type) -> Bool
    
    /// Register a singleton instance
    func registerSingleton<T>(_ type: T.Type, instance: T)
}

// MARK: - Thread-Safe Dependency Container
// As we are using DispatchQueue so it is thread safe hence used @unchecked Sendable
public final class DefaultDependencyContainer: DependencyContainer, ObservableObject, @unchecked Sendable {
    private let queue = DispatchQueue(label: "dependency.container", attributes: .concurrent)
    private var factories: [String: @Sendable () -> Any] = [:]
    private var singletons: [String: Any] = [:]
    
    public init() {}
    
    public func register<T>(_ type: T.Type, factory: @escaping @Sendable () -> T) {
        queue.async(flags: .barrier) {
            let key = String(describing: type)
            self.factories[key] = factory
        }
    }
    
    public func registerSingleton<T>(_ type: T.Type, instance: T) {
        queue.async(flags: .barrier) {
            let key = String(describing: type)
            self.singletons[key] = instance
        }
    }
    
    public func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        
        // Check if we have a singleton instance (read-only)
        if let singleton = queue.sync(execute: { singletons[key] as? T }) {
            return singleton
        }
        
        // Check if we have a factory (read-only)
        guard let factory = queue.sync(execute: { factories[key] }) else {
            fatalError("Dependency of type \(type) is not registered")
        }
        
        let instance = factory() as! T
        
        // Store singleton (write operation)
        queue.async(flags: .barrier) {
            self.singletons[key] = instance
        }
        
        return instance
    }
    
    public func isRegistered<T>(_ type: T.Type) -> Bool {
        let key = String(describing: type)
        return queue.sync { factories[key] != nil || singletons[key] != nil }
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
