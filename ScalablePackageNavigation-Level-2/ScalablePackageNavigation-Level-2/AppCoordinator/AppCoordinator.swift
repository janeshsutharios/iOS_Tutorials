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
    
    // Dependency Container - Single Source of Truth
    private let container: DependencyContainer
    
    // Routers - directly managed
    public let authRouter: AuthRouter
    public let dashboardRouter: DashboardRouter
    public let messagesRouter: MessagesRouter
    public let profileRouter: ProfileRouter
    
    // Type-Safe Navigation Coordinator
    private let navigationCoordinator = TypeSafeNavigationCoordinator()
    private let deepLinkCoordinator = DeepLinkCoordinator()
    private let analytics = DefaultNavigationAnalytics()
    
    // MARK: - Clean Initialization
    public init(container: DependencyContainer? = nil) {
        // Initialize dependency container
        self.container = container ?? DefaultDependencyContainer()
        
        // Initialize routers
        self.authRouter = AuthRouter()
        self.dashboardRouter = DashboardRouter()
        self.messagesRouter = MessagesRouter()
        self.profileRouter = ProfileRouter()
        
        // Register default services in container
        Task { [weak self] in
            guard let self = self else { return }
            
            // Register services with container
            await self.container.register(AuthServiceProtocol.self) { MockAuthService() }
            await self.container.register(DashboardServiceProtocol.self) { MockDashboardService() }
            await self.container.register(MessagesServiceProtocol.self) { MockMessagesService() }
            
            // Setup type-safe cross-feature navigation after services are registered
            await MainActor.run {
                self.setupTypeSafeNavigation()
            }
        }
    }
    
    // MARK: - Service Resolution (Clean Pattern)
    private func resolveAuthService() async -> AuthServiceProtocol {
        return await container.resolve(AuthServiceProtocol.self)
    }
    
    private func resolveDashboardService() async -> DashboardServiceProtocol {
        return await container.resolve(DashboardServiceProtocol.self)
    }
    
    private func resolveMessagesService() async -> MessagesServiceProtocol {
        return await container.resolve(MessagesServiceProtocol.self)
    }
    
    // MARK: - Service Registration (For Testing/Override)
    public func registerService<T: Sendable>(_ type: T.Type, factory: @escaping @Sendable () -> T) async {
        await container.register(type, factory: factory)
    }
    
    public func isServiceRegistered<T: Sendable>(_ type: T.Type) async -> Bool {
        return await container.isRegistered(type)
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
                let authService = await resolveAuthService()
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
