//
//  Router.swift
//  CoreNavigation
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI
import Combine

// MARK: - Router Protocol

@available(iOS 16.0, macOS 13.0, *)
@MainActor
public protocol Router: ObservableObject, Sendable {
    associatedtype Route: Hashable & Sendable
    var navigationPath: NavigationPath { get set }
    
    func navigate(to route: Route)
    func navigateBack()
    func navigateToRoot()
}

// MARK: - Base Router Implementation

@available(iOS 16.0, macOS 13.0, *)
@MainActor
open class BaseRouter<Route: Hashable & Sendable>: Router, ObservableObject {
    @Published public var navigationPath = NavigationPath()
    
    public init() {}
    
    public func navigate(to route: Route) {
        navigationPath.append(route)
    }
    
    public func navigateBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    public func navigateToRoot() {
        navigationPath = NavigationPath()
    }
}

// MARK: - Feature Router Protocol
@available(iOS 16.0, macOS 13.0, *)
@MainActor
public protocol FeatureRouter: Router {
    func navigateToFeatureRoute<OtherRoute: Hashable & Sendable>(_ feature: AppFeature, route: OtherRoute)
}

// MARK: - Base Feature Router Implementation
@available(iOS 16.0, macOS 13.0, *)
@MainActor
open class BaseFeatureRouter<Route: Hashable & Sendable>: BaseRouter<Route>, FeatureRouter {
    public override init() {
        super.init()
    }
    
    public func navigateToFeatureRoute<OtherRoute: Hashable & Sendable>(_ feature: AppFeature, route: OtherRoute) {
        // This method is now handled by the NavigationCoordinator
        // Features should use the NavigationEnvironment instead
        print("⚠️ navigateToFeatureRoute is deprecated. Use NavigationEnvironment.navigateToFeature instead.")
    }
}

