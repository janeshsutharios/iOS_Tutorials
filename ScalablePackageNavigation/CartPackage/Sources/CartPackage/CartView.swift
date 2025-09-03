import SwiftUI
import Combine
import AppRouter

public struct CartView: View {
    @EnvironmentObject var router: AppRouter

    public init() {}

    public var body: some View {
        VStack(spacing: 20) {
            Text("🛒 Cart")
                .font(.largeTitle)
            ForEach(router.cartItems, id: \.self) { item in
                Text(item)
            }
            Button("Place Order") {
                router.path.append(.summary)
            }
        }
    }
}
