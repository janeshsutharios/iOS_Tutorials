import SwiftUI
import AppRouter
import CartPackage
import OrderSummaryPackage

@main
struct ScalableNavigationApp: App {
    @StateObject var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                DashboardView()
                    .environmentObject(router)
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .cart:
                            CartView()
                                .environmentObject(router)
                        case .summary:
                            OrderSummaryView()
                                .environmentObject(router)
                        case .dashboard:
                            DashboardView()
                                .environmentObject(router)
                        }
                    }
            }
        }
    }
}
