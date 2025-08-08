// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI
import Combine

public enum Route {
    case dashboard
    case cart
    case summary
}

@available(iOS 13.0, *)
public class AppRouter: ObservableObject {
    @Published public var path: [Route] = []
    @Published public var cartItems: [String] = []
    public init() {}  // Add public initializer
}
