//
//  OrderViewModel.swift
//  FoodApp
//
//  Created by Janesh Suthar on 05/08/25.
//

import Foundation

class OrderViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isOrderPlaced = false
    @Published var errorMessage = ""
    
    private let orderService: OrderServiceProtocol
    
    init(orderService: OrderServiceProtocol = OrderService()) {
        self.orderService = orderService
    }
    
    func placeOrder(items: [FoodItem]) {
        isLoading = true
        errorMessage = ""
        
        let order = Order(
            id: UUID().uuidString,
            items: items,
            total: items.reduce(0) { $0 + $1.price },
            date: Date(),
            status: .pending
        )
        
        orderService.placeOrder(order: order) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    self?.isOrderPlaced = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
