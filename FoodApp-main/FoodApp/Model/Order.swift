//
//  Order.swift
//  FoodApp
//
//  Created by Janesh Suthar on 05/08/25.
//

import Foundation
struct Order: Identifiable, Codable {
    let id: String
    let items: [FoodItem]
    let total: Double
    let date: Date
    let status: OrderStatus
    
    enum OrderStatus: String, Codable {
        case pending, completed, cancelled
    }
}
