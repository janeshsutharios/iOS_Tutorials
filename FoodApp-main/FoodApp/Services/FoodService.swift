//
//  FoodService.swift
//  FoodApp
//
//  Created by Janesh Suthar on 05/08/25.
//

import Foundation

protocol FoodServiceProtocol {
    func fetchFoodItems(completion: @escaping (Result<[FoodItem], Error>) -> Void)
}

class FoodService: FoodServiceProtocol {
    func fetchFoodItems(completion: @escaping (Result<[FoodItem], Error>) -> Void) {
        // Simulate network request with mock data
        let mockItems = [
            FoodItem(id: "1", name: "Margherita Pizza", description: "Classic pizza with tomato sauce and mozzarella", price: 12.99, imageName: "pizza1", category: "Pizza"),
            FoodItem(id: "2", name: "Pepperoni Pizza", description: "Pizza with tomato sauce, mozzarella and pepperoni", price: 14.99, imageName: "pizza2", category: "Pizza"),
            FoodItem(id: "3", name: "Caesar Salad", description: "Fresh salad with Caesar dressing", price: 8.99, imageName: "salad", category: "Salad"),
            FoodItem(id: "4", name: "Pasta Carbonara", description: "Pasta with creamy sauce and bacon", price: 11.99, imageName: "pasta", category: "Pasta"),
            FoodItem(id: "5", name: "Tiramisu", description: "Classic Italian dessert", price: 6.99, imageName: "tiramisu", category: "Dessert")
        ]
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            completion(.success(mockItems))
        }
    }
}
