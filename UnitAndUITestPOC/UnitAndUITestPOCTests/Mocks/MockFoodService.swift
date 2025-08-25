//
//  MockFoodService.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import Foundation
@testable import UnitAndUITestPOC

actor MockFoodService: FoodServiceProtocol {
    private var shouldSucceed = true
    private var mockFoodItems: [FoodItem]?
    private var mockError: Error?
    private var fetchCallCount = 0
    private var lastToken: String?
    
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
    
    // MARK: - Test Helper Methods
    func setShouldSucceed(_ value: Bool) {
        shouldSucceed = value
    }
    
    func setMockFoodItems(_ items: [FoodItem]) {
        mockFoodItems = items
    }
    
    func setMockError(_ error: Error) {
        mockError = error
    }
    
    func getFetchCallCount() -> Int {
        return fetchCallCount
    }
    
    func getLastToken() -> String? {
        return lastToken
    }
    
    func reset() {
        shouldSucceed = true
        mockFoodItems = nil
        mockError = nil
        fetchCallCount = 0
        lastToken = nil
    }
}
