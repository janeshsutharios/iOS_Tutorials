//
//  Router.swift
//  CoreNavigation
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI
import Combine

// MARK: - Router Protocol
@MainActor
public protocol Router: ObservableObject, Sendable {
    associatedtype Route: Hashable & Sendable
    var navigationPath: NavigationPath { get set }
    
    func navigate(to route: Route)
    func navigateBack()
    func navigateToRoot()
}

// MARK: - Base Router Implementation
@MainActor
open class BaseRouter<Route: Hashable & Sendable>: Router, ObservableObject{
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
