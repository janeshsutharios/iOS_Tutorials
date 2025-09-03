// The Swift Programming Language
// https://docs.swift.org/swift-book
import Combine
public enum AppRoute: Hashable {
    case dashboard
    case cart(CartRoute)    // All cart-related routes
    case orders(OrderRoute) // All order-related routes
  //  case profile(ProfileRoute) // Like this we can cover more screens/modules
}

public enum CartRoute: Hashable {
    case addToCart
    case checkout
    case paymentMethods
}

public enum OrderRoute: Hashable {
    case orderPlaced
    case orderHistory
    case orderDetails(id: String)
}

final public class NavigationModel: ObservableObject {
    @Published public var appRoute: [AppRoute] = []
    public init() {}
}
