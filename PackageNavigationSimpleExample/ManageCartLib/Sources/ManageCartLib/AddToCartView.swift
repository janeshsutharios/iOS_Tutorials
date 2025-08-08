// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import SwiftUI
import NavigationLib

@available(iOS 14.0, *)

public struct AddToCartView: View {
    @Binding var path: [AppRoute]
    
    // Public initializer (required for cross-module use)
    public init(path: Binding<[AppRoute]>) {
        self._path = path
    }
    
    public var body: some View {
        Button("Place Order") {
            path.append(AppRoute.orders(.orderPlaced))
           
        }
    }
}
