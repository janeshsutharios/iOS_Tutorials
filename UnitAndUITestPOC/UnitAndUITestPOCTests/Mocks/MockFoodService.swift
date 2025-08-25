//
//  MockFoodService.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import Foundation
@testable import UnitAndUITestPOC

class MockFoodService: FoodServiceProtocol {
    var shouldSucceed = true
    var mockFoodItems: [FoodItem]?
    var mockError: Error?
    var fetchCallCount = 0
    var lastToken: String?
    
    func fetchFoodItems(token: String) async throws -> [FoodItem] {
        fetchCallCount += 1
        lastToken = token
        
        if !shouldSucceed {
            if let mockError = mockError {
                throw mockError
            } else {
                throw NetworkError.unknown
            }
        }
        
        if let mockFoodItems = mockFoodItems {
            return mockFoodItems
        }
        
        // Default success response
        return [
            FoodItem(
                id: 1,
                name: "Test Burger",
                description: "A delicious test burger",
                price: 9.99,
                imageUrl: "https://example.com/image.jpg",
                category: "Burgers"
            )
        ]
    }
    
    func reset() {
        shouldSucceed = true
        mockFoodItems = nil
        mockError = nil
        fetchCallCount = 0
        lastToken = nil
    }
}
