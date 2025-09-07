//
//  AppCoordinator.swift
//  ScalablePackageNavigation-Level-2
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI
import Combine
import CoreNavigation
import Auth
import Dashboard
import Messages
import Services
import Profile

// MARK: - Main App Coordinator
@MainActor
public final class AppCoordinator: ObservableObject, NavigationEnvironment {
    @Published var isAuthenticated: Bool = false
    @Published var activeTab: AppTab = .dashboard
    
    public enum AppTab: Hashable { case dashboard, messages, profile }
    
    // Dependency Container
    private let container: DependencyContainer
    
    // Services - resolved from container
    private let authService: AuthServiceProtocol
    private let dashboardService: DashboardServiceProtocol
    private let messagesService: MessagesServiceProtocol
    
    // Routers - directly managed
    public let authRouter: AuthRouter
    public let dashboardRouter: DashboardRouter
    public let messagesRouter: MessagesRouter
    public let profileRouter: ProfileRouter
    
    // Type-Safe Navigation Coordinator
    private let navigationCoordinator = NavigationCoordinator()
    
    public init(
        container: DependencyContainer? = nil,
        authService: AuthServiceProtocol? = nil,
        dashboardService: DashboardServiceProtocol? = nil,
        messagesService: MessagesServiceProtocol? = nil
    ) {
        // Initialize dependency container
        self.container = container ?? DefaultDependencyContainer()
        
        // Initialize services with dependency injection
        self.authService = authService ?? self.container.resolve(AuthServiceProtocol.self)
        self.dashboardService = dashboardService ?? self.container.resolve(DashboardServiceProtocol.self)
        self.messagesService = messagesService ?? self.container.resolve(MessagesServiceProtocol.self)
        
        // Initialize routers
        self.authRouter = AuthRouter()
        self.dashboardRouter = DashboardRouter()
        self.messagesRouter = MessagesRouter()
        self.profileRouter = ProfileRouter()
        
        // Register services in container if not already registered
        if !self.container.isRegistered(AuthServiceProtocol.self) {
            self.container.register(AuthServiceProtocol.self) { self.authService }
        }
        if !self.container.isRegistered(DashboardServiceProtocol.self) {
            self.container.register(DashboardServiceProtocol.self) { self.dashboardService }
        }
        if !self.container.isRegistered(MessagesServiceProtocol.self) {
            self.container.register(MessagesServiceProtocol.self) { self.messagesService }
        }
        
        // Setup type-safe cross-feature navigation
        setupTypeSafeNavigation()
    }
    
    
    private func setupTypeSafeNavigation() {
        // Register type-safe navigation handlers
        navigationCoordinator.registerNavigationHandler(for: .dashboard) { [weak self] route in
            if let dashboardRoute = route as? DashboardRoute {
                self?.dashboardRouter.navigate(to: dashboardRoute)
                self?.activeTab = .dashboard
            } else {
                print("⚠️ Invalid route type for dashboard: \(type(of: route))")
            }
        }
        
        navigationCoordinator.registerNavigationHandler(for: .messages) { [weak self] route in
            if let messagesRoute = route as? MessagesRoute {
                self?.messagesRouter.navigate(to: messagesRoute)
                self?.activeTab = .messages
            } else {
                print("⚠️ Invalid route type for messages: \(type(of: route))")
            }
        }
        
        navigationCoordinator.registerNavigationHandler(for: .profile) { [weak self] route in
            if let profileRoute = route as? ProfileRoute {
                self?.profileRouter.navigate(to: profileRoute)
                self?.activeTab = .profile
            } else {
                print("⚠️ Invalid route type for profile: \(type(of: route))")
            }
        }
        
        navigationCoordinator.registerNavigationHandler(for: .auth) { [weak self] route in
            if let authRoute = route as? AuthRoute {
                self?.authRouter.navigate(to: authRoute)
            } else {
                print("⚠️ Invalid route type for auth: \(type(of: route))")
            }
        }
    }
    
    public func logout() {
        Task {
            do {
                _ = try await authService.logout()
                isAuthenticated = false
                // Reset all navigation stacks
                authRouter.navigateToRoot()
                dashboardRouter.navigateToRoot()
                messagesRouter.navigateToRoot()
                profileRouter.navigateToRoot()
            } catch {
                print("Logout error: \(error)")
            }
        }
    }
    
    // MARK: - NavigationEnvironment conformance
    public func navigate<Route: Hashable & Sendable>(to route: Route) {
        // This is a generic navigation method that can be used for cross-feature navigation
        if let authRoute = route as? AuthRoute {
            authRouter.navigate(to: authRoute)
        } else if let dashboardRoute = route as? DashboardRoute {
            dashboardRouter.navigate(to: dashboardRoute)
            activeTab = .dashboard
        } else if let messagesRoute = route as? MessagesRoute {
            messagesRouter.navigate(to: messagesRoute)
            activeTab = .messages
        } else if let profileRoute = route as? ProfileRoute {
            profileRouter.navigate(to: profileRoute)
            activeTab = .profile
        }
    }
    
    public func navigateBack() {
        switch activeTab {
        case .dashboard:
            dashboardRouter.navigateBack()
        case .messages:
            messagesRouter.navigateBack()
        case .profile:
            profileRouter.navigateBack()
        }
    }
    
    public func navigateToRoot() {
        switch activeTab {
        case .dashboard:
            dashboardRouter.navigateToRoot()
        case .messages:
            messagesRouter.navigateToRoot()
        case .profile:
            profileRouter.navigateToRoot()
        }
    }
    
    // MARK: - Type-Safe Cross-Feature Navigation
    public func navigateToFeature<Route: Hashable & Sendable>(_ feature: AppFeature, route: Route) {
        navigationCoordinator.navigateToFeature(feature, route: route)
    }
}
