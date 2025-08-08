import SwiftUI
import Router

@available(iOS 13.0, *)
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
