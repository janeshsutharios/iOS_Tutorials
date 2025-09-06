//
//  AppCoordinator.swift
//  ScalablePackageNavigation-Level-2
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI
import Combine
import Auth
import Dashboard
import Messages
import Services

// MARK: - Main App Coordinator
@MainActor
public class AppCoordinator: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var activeTab: AppTab = .dashboard
    
    public enum AppTab: Hashable { case dashboard, messages, profile }
    
    // Services
    let authService: AuthServiceProtocol
    let dashboardService: DashboardServiceProtocol
    let messagesService: MessagesServiceProtocol
    
    // Routers
    let authRouter: AuthRouter
    let dashboardRouter: DashboardRouter
    let messagesRouter: MessagesRouter
    
    public init(
        authService: AuthServiceProtocol = MockAuthService(),
        dashboardService: DashboardServiceProtocol = MockDashboardService(),
        messagesService: MessagesServiceProtocol = MockMessagesService()
    ) {
        self.authService = authService
        self.dashboardService = dashboardService
        self.messagesService = messagesService
        
        self.authRouter = AuthRouter()
        self.dashboardRouter = DashboardRouter()
        self.messagesRouter = MessagesRouter()
    }
    
    public func logout() {
        Task {
            do {
                _ = try await authService.logout()
                isAuthenticated = false
            } catch {
                // Handle logout error if needed
                print("Logout error: \(error)")
            }
        }
    }
}
