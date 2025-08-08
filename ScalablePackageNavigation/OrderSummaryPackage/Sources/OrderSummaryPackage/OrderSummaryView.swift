import SwiftUI
import Combine
import AppRouter

@available(iOS 13.0, *)
public struct OrderSummaryView: View {
    @EnvironmentObject var router: AppRouter

    public init() {}

    public var body: some View {
        VStack(spacing: 20) {
            Text("📦 Order Summary")
                .font(.largeTitle)
            ForEach(router.cartItems, id: \.self) { item in
                Text("Ordered: \(item)")
            }
            Button("Go to Home") {
                router.path = []
                router.cartItems.removeAll()
            }
            .navigationBarBackButtonHidden()
        }
    }
}
