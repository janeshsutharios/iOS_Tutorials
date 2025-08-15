import SwiftUI

@main
struct JWTClientProApp: App {
    @State private var container = AppContainer.make(current: .dev)
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RootView(api: container.api)
                    .environmentObject(container.authService)
            }
        }
    }
}

struct RootView: View {
    @EnvironmentObject var auth: AuthService
    let api: APIService
    
    var body: some View {
        if auth.isAuthenticated {
            DashboardView(api: api)
        } else {
            LoginView()
        }
    }
}
