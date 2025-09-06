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
public enum AuthRoute: Hashable, Sendable {
    case login
    case signup
    case forgotPassword
    case verification
}

// MARK: - Auth Router
@MainActor
public final class AuthRouter: BaseRouter<AuthRoute> {
    public override init() {
        super.init()
    }
}

// MARK: - Auth Navigation Container
public struct AuthNavigationContainer: View {
    @StateObject private var router = AuthRouter()
    let onLoginSuccess: () -> Void
    
    public init(onLoginSuccess: @escaping () -> Void = {}) {
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
