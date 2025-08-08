import SwiftUI

@main
struct ModularCartApp: App {
    @StateObject private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                DashboardView()
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .dashboard:
                            DashboardView()
                        case .cart:
                            CartView()
                        case .summary:
                            OrderSummaryView()
                        }
                    }
                    .environmentObject(router)
            }
        }
    }
}