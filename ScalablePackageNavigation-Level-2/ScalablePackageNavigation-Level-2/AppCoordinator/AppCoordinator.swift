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
@available(iOS 16.0, macOS 13.0, *)
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
    private let navigationCoordinator = TypeSafeNavigationCoordinator()
    private let deepLinkCoordinator = DeepLinkCoordinator()
    private let analytics = DefaultNavigationAnalytics()
    
    public init(
        container: DependencyContainer? = nil,
        authService: AuthServiceProtocol? = nil,
        dashboardService: DashboardServiceProtocol? = nil,
        messagesService: MessagesServiceProtocol? = nil
    ) {
        // Initialize dependency container
        self.container = container ?? DefaultDependencyContainer()
        
        // Initialize services with provided instances or default mock services
        self.authService = authService ?? MockAuthService()
        self.dashboardService = dashboardService ?? MockDashboardService()
        self.messagesService = messagesService ?? MockMessagesService()
        
        // Initialize routers
        self.authRouter = AuthRouter()
        self.dashboardRouter = DashboardRouter()
        self.messagesRouter = MessagesRouter()
        self.profileRouter = ProfileRouter()
        
        // Register services in container asynchronously
        Task { [weak self] in
            guard let self = self else { return }
            
            if !(await self.container.isRegistered(AuthServiceProtocol.self)) {
                await self.container.register(AuthServiceProtocol.self) { self.authService }
            }
            if !(await self.container.isRegistered(DashboardServiceProtocol.self)) {
                await self.container.register(DashboardServiceProtocol.self) { self.dashboardService }
            }
            if !(await self.container.isRegistered(MessagesServiceProtocol.self)) {
                await self.container.register(MessagesServiceProtocol.self) { self.messagesService }
            }
        }
        
        // Setup type-safe cross-feature navigation
        setupTypeSafeNavigation()
    }
    
    
    private func setupTypeSafeNavigation() {
        // Register type-safe navigation handlers using the new system
        navigationCoordinator.registerHandler(for: DashboardRoute.self) { [weak self] route in
            self?.dashboardRouter.navigate(to: route)
            self?.activeTab = .dashboard
            Task { [weak self] in
                await self?.analytics.trackNavigation(from: "app", to: "dashboard", route: String(describing: route))
            }
        }
        
        navigationCoordinator.registerHandler(for: MessagesRoute.self) { [weak self] route in
            self?.messagesRouter.navigate(to: route)
            self?.activeTab = .messages
            Task { [weak self] in
                await self?.analytics.trackNavigation(from: "app", to: "messages", route: String(describing: route))
            }
        }
        
        navigationCoordinator.registerHandler(for: ProfileRoute.self) { [weak self] route in
            self?.profileRouter.navigate(to: route)
            self?.activeTab = .profile
            Task { [weak self] in
                await self?.analytics.trackNavigation(from: "app", to: "profile", route: String(describing: route))
            }
        }
        
        navigationCoordinator.registerHandler(for: AuthRoute.self) { [weak self] route in
            self?.authRouter.navigate(to: route)
            Task { [weak self] in
                await self?.analytics.trackNavigation(from: "app", to: "auth", route: String(describing: route))
            }
        }
        
        // Setup deep linking
        setupDeepLinking()
    }
    
    private func setupDeepLinking() {
        // Register deep link handlers
        deepLinkCoordinator.register(URLSchemeDeepLinkHandler(
            scheme: "scalableapp",
            handler: { [weak self] url in
                return await self?.handleDeepLink(url: url) ?? .failure(.deepLinkParsingFailed(url))
            }
        ))
    }
    
    private func handleDeepLink(url: URL) async -> NavigationResult {
        // Parse deep link and navigate accordingly
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let host = components.host else {
            return .failure(.deepLinkParsingFailed(url))
        }
        
        switch host {
        case "dashboard":
            navigationCoordinator.navigate(to: DashboardRoute.home)
            return .success
        case "messages":
            navigationCoordinator.navigate(to: MessagesRoute.inbox)
            return .success
        case "profile":
            navigationCoordinator.navigate(to: ProfileRoute.profile)
            return .success
        default:
            return .failure(.deepLinkParsingFailed(url))
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
    public func navigateToFeature<Route: TypedRoute>(_ route: Route) {
        navigationCoordinator.navigate(to: route)
    }
    
    // MARK: - Legacy Cross-Feature Navigation (for backward compatibility)
    public func navigateToFeature<Route: Hashable & Sendable>(_ feature: AppFeature, route: Route) {
        // Convert to typed route navigation
        switch feature {
        case .dashboard:
            if let dashboardRoute = route as? DashboardRoute {
                navigationCoordinator.navigate(to: dashboardRoute)
            }
        case .messages:
            if let messagesRoute = route as? MessagesRoute {
                navigationCoordinator.navigate(to: messagesRoute)
            }
        case .profile:
            if let profileRoute = route as? ProfileRoute {
                navigationCoordinator.navigate(to: profileRoute)
            }
        case .auth:
            if let authRoute = route as? AuthRoute {
                navigationCoordinator.navigate(to: authRoute)
            }
        }
    }
}
