//
//  Auth.swift
//  Auth
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI
import CoreNavigation
import Services

// MARK: - Auth Route
@available(iOS 16.0, macOS 13.0, *)
public enum AuthRoute: TypedRoute {
    case login
    case signup
    case forgotPassword
    case verification
    
    public static var feature: AppFeature { .auth }
}

// MARK: - Auth Router

@available(iOS 16.0, macOS 13.0, *)
@MainActor
public final class AuthRouter: BaseFeatureRouter<AuthRoute> {
    public override init() {
        super.init()
    }
}

// MARK: - Auth Navigation Container

@available(iOS 16.0, macOS 13.0, *)
public struct AuthNavigationContainer: View {
    @StateObject private var router: AuthRouter
    let onLoginSuccess: () -> Void
    
    public init(
        router: AuthRouter? = nil,
        onLoginSuccess: @escaping () -> Void = {}
    ) {
        self._router = StateObject(wrappedValue: router ?? AuthRouter())
        self.onLoginSuccess = onLoginSuccess
    }
    
    public var body: some View {
        NavigationStack(path: $router.navigationPath) {
            LoginView(onLoginSuccess: onLoginSuccess)
                .navigationDestination(for: AuthRoute.self) { route in
                    destinationView(for: route)
                }
        }
        .environmentObject(router)
    }
    
    @ViewBuilder
    private func destinationView(for route: AuthRoute) -> some View {
        switch route {
        case .login:
            LoginView(onLoginSuccess: onLoginSuccess)
        case .signup:
            SignupView(onLoginSuccess: onLoginSuccess)
        case .forgotPassword:
            ForgotPasswordView()
        case .verification:
            VerificationView()
        }
    }
}
