//
//  OrderService.swift
//  FoodApp
//
//  Created by Janesh Suthar on 05/08/25.
//

import Foundation

protocol OrderServiceProtocol {
    func placeOrder(order: Order, completion: @escaping (Result<Void, Error>) -> Void)
}

class OrderService: OrderServiceProtocol {
    func placeOrder(order: Order, completion: @escaping (Result<Void, Error>) -> Void) {
        // Simulate network request
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            completion(.success(()))
        }
    }
}
