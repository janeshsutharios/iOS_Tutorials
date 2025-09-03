// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI
import Combine

// In AppRouter module
public enum Route: Hashable {
    case dashboard
    case cart(cartItems: [String])
    case summary(orderedItems: [String]) 
}

public class AppRouter: ObservableObject {
    @Published public var path: [Route] = []
    public init() {}  
}
