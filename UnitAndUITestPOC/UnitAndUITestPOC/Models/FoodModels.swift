//
//  FoodModels.swift
//  UnitAndUITestPOC
//
//  Created by Janesh Suthar on 25/08/25.
//

import Foundation

// MARK: - Food Item
struct FoodItem: Codable, Identifiable, Hashable, Sendable {
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
    nonisolated init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.price = try container.decode(Double.self, forKey: .price)
        self.imageUrl = try container.decode(String.self, forKey: .imageUrl)
        self.category = try container.decode(String.self, forKey: .category)
    }
    
    init(id: Int, name: String, description: String, price: Double, imageUrl: String, category: String) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.imageUrl = imageUrl
        self.category = category
    }
}

// MARK: - Food Items Response
struct FoodItemsResponse: Codable, Sendable {
    let foodItems: [FoodItem]
    
    // Regular initializer
    init(foodItems: [FoodItem]) {
        self.foodItems = foodItems
    }
    
    nonisolated init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.foodItems = try container.decode([FoodItem].self, forKey: .foodItems)
    }
    
    nonisolated func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(foodItems, forKey: .foodItems)
    }
    
    enum CodingKeys: String, CodingKey {
        case foodItems
    }
}

// MARK: - Food Loading State
enum FoodLoadingState: Equatable, Sendable {
    case idle
    case loading
    case loaded([FoodItem])
    case error(String)
}
