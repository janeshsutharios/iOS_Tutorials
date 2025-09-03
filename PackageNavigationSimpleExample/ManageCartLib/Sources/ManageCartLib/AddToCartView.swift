// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import SwiftUI
import NavigationLib

public struct AddToCartView: View {
    public init() {}
    
    @EnvironmentObject var navModel: NavigationModel
    public var body: some View {
        Button("Place Order") {
            navModel.appRoute.append(AppRoute.orders(.orderPlaced))
           
        }
    }
}

/*
If you use  @Binding var path: [AppRoute]
// Public initializer (required for cross-module use)
public init(path: Binding<[AppRoute]>) {
    self._path = path
}*/
