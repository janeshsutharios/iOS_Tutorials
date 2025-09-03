//
//  CartViewModel.swift
//  FoodApp
//
//  Created by Janesh Suthar on 05/08/25.
//

import Foundation

class CartViewModel: ObservableObject {
    @Published var cartItems: [FoodItem] = []
    @Published var isLoading = false
    
    var totalPrice: Double {
        cartItems.reduce(0) { $0 + $1.price }
    }
    
    func addToCart(item: FoodItem) {
        cartItems.append(item)
    }
    
    func removeFromCart(at indexSet: IndexSet) {
        cartItems.remove(atOffsets: indexSet)
    }
}
