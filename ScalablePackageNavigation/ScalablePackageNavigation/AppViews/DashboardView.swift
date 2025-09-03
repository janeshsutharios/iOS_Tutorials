import SwiftUI
import CartPackage
import AppRouter

struct DashboardView: View {
    @EnvironmentObject var router: AppRouter
    let foodItems: [String] = ["🍕 Pizza", "☕ Coffee"]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🍕 Dashboard")
                .font(.largeTitle)
            Button("Add Food items into Cart") {
                router.path.append(.cart(cartItems: foodItems))
            }
        }
    }
}
