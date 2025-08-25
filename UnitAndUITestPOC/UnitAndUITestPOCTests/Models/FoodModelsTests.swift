//
//  FoodModelsTests.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import XCTest
@testable import UnitAndUITestPOC

final class FoodModelsTests: XCTestCase {
    
    func testFoodItemEncoding() throws {
        // Given
        let foodItem = FoodItem(
            id: 1,
            name: "Test Burger",
            description: "A delicious test burger",
            price: 9.99,
            imageUrl: "https://example.com/image.jpg",
            category: "Burgers"
        )
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(foodItem)
        let jsonString = String(data: data, encoding: .utf8)
        
        // Then
        XCTAssertNotNil(jsonString)
        XCTAssertTrue(jsonString?.contains("Test Burger") ?? false)
        XCTAssertTrue(jsonString?.contains("9.99") ?? false)
    }
    
    func testFoodItemDecoding() throws {
        // Given
        let jsonString = """
        {
            "id": 1,
            "name": "Test Burger",
            "description": "A delicious test burger",
            "price": 9.99,
            "imageUrl": "https://example.com/image.jpg",
            "category": "Burgers"
        }
        """
        let data = jsonString.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let foodItem = try decoder.decode(FoodItem.self, from: data)
        
        // Then
        XCTAssertEqual(foodItem.id, 1)
        XCTAssertEqual(foodItem.name, "Test Burger")
        XCTAssertEqual(foodItem.description, "A delicious test burger")
        XCTAssertEqual(foodItem.price, 9.99)
        XCTAssertEqual(foodItem.imageUrl, "https://example.com/image.jpg")
        XCTAssertEqual(foodItem.category, "Burgers")
    }
    
    func testFoodItemFormattedPrice() {
        // Given
        let foodItem1 = FoodItem(
            id: 1,
            name: "Test Item",
            description: "Test",
            price: 9.99,
            imageUrl: "https://example.com/image.jpg",
            category: "Test"
        )
        
        let foodItem2 = FoodItem(
            id: 2,
            name: "Test Item 2",
            description: "Test",
            price: 10.0,
            imageUrl: "https://example.com/image.jpg",
            category: "Test"
        )
        
        // When & Then
        XCTAssertEqual(foodItem1.formattedPrice, "$9.99")
        XCTAssertEqual(foodItem2.formattedPrice, "$10.00")
    }
    
    func testFoodItemHashable() {
        // Given
        let foodItem1 = FoodItem(
            id: 1,
            name: "Test Item",
            description: "Test",
            price: 9.99,
            imageUrl: "https://example.com/image.jpg",
            category: "Test"
        )
        
        let foodItem2 = FoodItem(
            id: 1,
            name: "Test Item",
            description: "Test",
            price: 9.99,
            imageUrl: "https://example.com/image.jpg",
            category: "Test"
        )
        
        let foodItem3 = FoodItem(
            id: 2,
            name: "Different Item",
            description: "Test",
            price: 9.99,
            imageUrl: "https://example.com/image.jpg",
            category: "Test"
        )
        
        // When & Then
        XCTAssertEqual(foodItem1.hashValue, foodItem2.hashValue)
        XCTAssertNotEqual(foodItem1.hashValue, foodItem3.hashValue)
    }
    
    func testFoodItemsResponseDecoding() throws {
        // Given
        let jsonString = """
        {
            "foodItems": [
                {
                    "id": 1,
                    "name": "Test Burger",
                    "description": "A delicious test burger",
                    "price": 9.99,
                    "imageUrl": "https://example.com/image.jpg",
                    "category": "Burgers"
                }
            ]
        }
        """
        let data = jsonString.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let response = try decoder.decode(FoodItemsResponse.self, from: data)
        
        // Then
        XCTAssertEqual(response.foodItems.count, 1)
        XCTAssertEqual(response.foodItems.first?.name, "Test Burger")
    }
    
    func testFoodLoadingStateEquality() {
        // Given & When & Then
        XCTAssertEqual(FoodLoadingState.idle, FoodLoadingState.idle)
        XCTAssertEqual(FoodLoadingState.loading, FoodLoadingState.loading)
        XCTAssertEqual(FoodLoadingState.loaded([]), FoodLoadingState.loaded([]))
        XCTAssertEqual(FoodLoadingState.error("test"), FoodLoadingState.error("test"))
        XCTAssertNotEqual(FoodLoadingState.error("test1"), FoodLoadingState.error("test2"))
    }
}
