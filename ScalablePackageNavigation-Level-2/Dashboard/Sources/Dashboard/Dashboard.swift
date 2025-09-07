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
    case detail(String)
}

// MARK: - Dashboard Router

@MainActor
public final class DashboardRouter: BaseFeatureRouter<DashboardRoute> {
    public override init() {
        super.init()
    }
}

// MARK: - Dashboard Navigation Container

public struct DashboardNavigationContainer: View {
    @StateObject private var router: DashboardRouter
    
    public init(router: DashboardRouter? = nil) {
        self._router = StateObject(wrappedValue: router ?? DashboardRouter())
    }
    
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
        case .detail(let id):
            DetailView(itemId: id)
        }
    }
}
