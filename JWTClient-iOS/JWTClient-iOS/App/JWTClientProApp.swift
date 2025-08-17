import SwiftUI

@main
struct JWTClientProApp: App {
    // Dependency injection container for all services
    @State private var container = AppContainer.make(current: .dev)
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                // Root view that switches between login and dashboard based on auth state
                RootView(api: container.api)
                    .environmentObject(container.authService)
            }
        }
    }
}

// Main navigation view that observes authentication state
struct RootView: View {
    @EnvironmentObject var auth: AuthService
    @State private var showAlert = false
    let api: APIService

    var body: some View {
        Group {
            if auth.isAuthenticated {
                // Show dashboard when user is authenticated
                DashboardView(api: api)
            } else {
                // Show login when user is not authenticated
                LoginView()
            }
        }
        .onChange(of: auth.authMessage, { oldValue, newValue in
            showAlert = newValue != nil
        })
        .alert(isPresented: $showAlert) {
            // Refresh token is expired so user has to login again.
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
