// The Swift Programming Language
// https://docs.swift.org/swift-book
public enum AppRoute: Hashable {
    case dashboard
    case cart(CartRoute)    // All cart-related routes
    case orders(OrderRoute) // All order-related routes
  //  case profile(ProfileRoute)
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
