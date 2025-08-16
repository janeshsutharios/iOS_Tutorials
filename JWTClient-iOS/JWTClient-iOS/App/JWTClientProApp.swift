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
    let api: APIService
    
    var body: some View {
        if auth.isAuthenticated {
            // Show dashboard when user is authenticated
            DashboardView(api: api)
        } else {
            // Show login when user is not authenticated
            LoginView()
        }
    }
}
