// In ModularCartApp.swift
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
                        case .cart(let cartItems):
                            CartView(cartItems: cartItems)
                                .environmentObject(router)
                        case .summary(let orderedItems): // Extract the associated value
                            OrderSummaryView(orderedItems: orderedItems) // Pass it here
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
