import SwiftUI

@main
struct JWTClientProApp: App {
    // MARK: - Dependency Injection
    // AppContainer creates and manages all services (HTTP, Auth, API, etc.)
    // This ensures proper service lifecycle and testability
    @State private var container = AppContainer.make(current: .dev)
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                // MARK: - Root Navigation
                // RootView observes authentication state and routes between Login/Dashboard
                // AuthService is injected as environment object for all child views
                RootView(api: container.api)
                    .environmentObject(container.authService)
            }
        }
    }
}

// MARK: - Root Navigation Logic
// RootView is the main coordinator that switches between Login and Dashboard
// based on authentication state. It also handles global auth error alerts.
struct RootView: View {
    // MARK: - Dependencies
    @EnvironmentObject var auth: AuthService  // Injected from parent
    @State private var showAlert = false     // Controls auth error alerts
    let api: APIService                      // API service for dashboard

    var body: some View {
        Group {
            // MARK: - Conditional Navigation
            // Routes to Dashboard when authenticated, Login when not
            if auth.isAuthenticated {
                DashboardView(api: api)
            } else {
                LoginView()
            }
        }
        .onChange(of: auth.authMessage, { oldValue, newValue in
            // MARK: - Global Error Handling
            // Shows alert when auth errors occur (e.g., expired refresh token)
            showAlert = newValue != nil
        })
        .alert(isPresented: $showAlert) {
            // MARK: - Session Expired Alert
            // Informs user when refresh token is expired and login is required
            Alert(
                title: Text("Session Expired"),
                message: Text(auth.authMessage ?? "Please log in again."),
                dismissButton: .default(Text("OK")) {
                    auth.authMessage = nil
                }
            )
        }
    }
}
