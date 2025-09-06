//
//  MessagesRoute.swift
//  Profile
//
//  Created by Janesh Suthar on 06/09/25.
//


import SwiftUI
import CoreNavigation
import Services

// MARK: - Profile Route
public enum ProfileRoute: Hashable, Sendable {
    case profile
    case settings
}

// MARK: - Profile Router
@MainActor
public final class ProfileRouter: BaseRouter<ProfileRoute> {
    public override init() {
        super.init()
    }
}

// MARK: - Profile Navigation Container
public struct ProfileNavigationContainer: View {
    @StateObject private var router = ProfileRouter()
    
    public init() {}
    
    public var body: some View {
        NavigationStack(path: $router.navigationPath) {
            ProfileView()
                .navigationDestination(for: ProfileRoute.self) { route in
                    destinationView(for: route)
                }
        }
        .environmentObject(router)
    }
    
    @ViewBuilder
    private func destinationView(for route: ProfileRoute) -> some View {
        switch route {
        case .profile:
            ProfileView()
        case .settings:
            SettingsView()
        }
    }
}
