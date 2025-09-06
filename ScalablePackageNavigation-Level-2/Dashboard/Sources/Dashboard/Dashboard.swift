//
//  Dashboard.swift
//  Dashboard
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI
import CoreNavigation
import Services

// MARK: - Dashboard Route
public enum DashboardRoute: Hashable, Sendable {
    case home
    case profile
    case settings
    case detail(String)
}

// MARK: - Dashboard Router
@MainActor
public final class DashboardRouter: BaseRouter<DashboardRoute> {
    public override init() {
        super.init()
    }
}

// MARK: - Dashboard Navigation Container
public struct DashboardNavigationContainer: View {
    @StateObject private var router = DashboardRouter()
    
    public init() {}
    
    public var body: some View {
        NavigationStack(path: $router.navigationPath) {
            HomeView()
                .navigationDestination(for: DashboardRoute.self) { route in
                    destinationView(for: route)
                }
        }
        .environmentObject(router)
    }
    
    @ViewBuilder
    private func destinationView(for route: DashboardRoute) -> some View {
        switch route {
        case .home:
            HomeView()
        case .profile:
            ProfileView()
        case .settings:
            SettingsView()
        case .detail(let id):
            DetailView(itemId: id)
        }
    }
}
