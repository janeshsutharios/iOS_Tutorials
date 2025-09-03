import SwiftUI
import Combine
import AppRouter

public struct CartView: View {
    @EnvironmentObject var router: AppRouter
    public let cartItems: [String]
    
    public init(cartItems: [String]) {
        self.cartItems = cartItems
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("🛒 Cart")
                .font(.largeTitle)
            
            List(cartItems, id: \.self) { item in
                Text(item)
            }
            
            Button("Proceed to Checkout") {
                // Pass the cart items to the summary view
                router.path.append(.summary(orderedItems: cartItems))
            }
            .padding()
        }
    }
}
