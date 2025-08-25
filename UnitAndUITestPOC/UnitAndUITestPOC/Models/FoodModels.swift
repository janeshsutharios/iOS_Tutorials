//
//  FoodModels.swift
//  UnitAndUITestPOC
//
//  Created by Janesh Suthar on 25/08/25.
//

import Foundation

// MARK: - Food Item
struct FoodItem: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let description: String
    let price: Double
    let imageUrl: String
    let category: String
    
    // Computed property for formatted price
    var formattedPrice: String {
        return String(format: "$%.2f", price)
    }
}

// MARK: - Food Items Response
struct FoodItemsResponse: Codable {
    let foodItems: [FoodItem]
}

// MARK: - Food Loading State
enum FoodLoadingState {
    case idle
    case loading
    case loaded([FoodItem])
    case error(String)
}
