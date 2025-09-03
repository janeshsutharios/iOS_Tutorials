import SwiftUI
import CartPackage
import AppRouter

struct DashboardView: View {
    @EnvironmentObject var router: AppRouter

    var body: some View {
        VStack(spacing: 20) {
            Text("🍕 Dashboard")
                .font(.largeTitle)
            Button("Add Pizza to Cart") {
                router.path.append(.cart(cartItems: ["🍕 Pizza"]))
            }
        }
    }
}
