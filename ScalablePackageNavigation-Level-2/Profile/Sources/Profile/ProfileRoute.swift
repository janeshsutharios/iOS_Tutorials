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
@available(iOS 16.0, macOS 13.0, *)
public enum ProfileRoute: TypedRoute {
    case profile
    case settings
    
    public static var feature: AppFeature { .profile }
}

// MARK: - Profile Router

@available(iOS 16.0, macOS 13.0, *)
@MainActor
public final class ProfileRouter: BaseFeatureRouter<ProfileRoute> {
    public override init() {
        super.init()
    }
}

// MARK: - Profile Navigation Container

@available(iOS 16.0, macOS 13.0, *)
public struct ProfileNavigationContainer: View {
    @StateObject private var router: ProfileRouter
    
    public init(router: ProfileRouter? = nil) {
        self._router = StateObject(wrappedValue: router ?? ProfileRouter())
    }
    
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
