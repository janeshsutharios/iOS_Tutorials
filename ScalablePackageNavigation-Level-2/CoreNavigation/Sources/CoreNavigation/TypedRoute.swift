//
//  TypedRoute.swift
//  CoreNavigation
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI

// MARK: - Typed Route Protocol
/// Protocol for compile-time type-safe routes
@available(iOS 16.0, macOS 13.0, *)
public protocol TypedRoute: Hashable, Sendable {
    /// The feature this route belongs to
    static var feature: AppFeature { get }
    
    /// Convert to AnyHashable for navigation
    var asAnyHashable: AnyHashable { get }
}

// MARK: - Typed Route Default Implementation
@available(iOS 16.0, macOS 13.0, *)
public extension TypedRoute {
    var asAnyHashable: AnyHashable {
        return AnyHashable(self)
    }
}

// MARK: - Type-Safe Navigation Coordinator
/// Enhanced navigation coordinator with type safety
@available(iOS 16.0, macOS 13.0, *)
@MainActor
public final class TypeSafeNavigationCoordinator: ObservableObject, Sendable {
    private var navigationHandlers: [AppFeature: (AnyHashable) -> Void] = [:]
    private var routeValidators: [AppFeature: (AnyHashable) -> Bool] = [:]
    
    public init() {}
    
    /// Register a type-safe navigation handler
    public func registerHandler<Route: TypedRoute>(
        for routeType: Route.Type,
        handler: @escaping (Route) -> Void
    ) {
        let feature = routeType.feature
        navigationHandlers[feature] = { anyRoute in
            if let typedRoute = anyRoute as? Route {
                handler(typedRoute)
            } else {
                print("⚠️ Type mismatch: expected \(Route.self), got \(type(of: anyRoute))")
            }
        }
        
        // Register route validator
        routeValidators[feature] = { anyRoute in
            return anyRoute is Route
        }
    }
    
    /// Navigate with type safety
    public func navigate<Route: TypedRoute>(to route: Route) {
        let feature = Route.feature
        
        guard let handler = navigationHandlers[feature] else {
            print("⚠️ No navigation handler registered for feature: \(feature.rawValue)")
            return
        }
        
        guard let validator = routeValidators[feature],
              validator(route.asAnyHashable) else {
            print("⚠️ Invalid route type for feature: \(feature.rawValue)")
            return
        }
        
        handler(route.asAnyHashable)
    }
    
    /// Check if a feature has a registered handler
    public func hasHandler(for feature: AppFeature) -> Bool {
        return navigationHandlers[feature] != nil
    }
    
    /// Validate a route for a feature
    public func validateRoute(_ route: AnyHashable, for feature: AppFeature) -> Bool {
        guard let validator = routeValidators[feature] else {
            return false
        }
        return validator(route)
    }
}
