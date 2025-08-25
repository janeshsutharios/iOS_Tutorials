//
//  FoodModelsSwiftTests.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import Testing
@testable import UnitAndUITestPOC

@Suite("Food Models")
struct FoodModelsSwiftTests {
    
    @Test("FoodItem encoding produces valid JSON")
    func testFoodItemEncoding() throws {
        let foodItem = FoodItem(
            id: 1,
            name: "Test Burger",
            description: "A delicious test burger",
            price: 9.99,
            imageUrl: "https://example.com/image.jpg",
            category: "Burgers"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(foodItem)
        let jsonString = String(data: data, encoding: .utf8)
        
        #expect(jsonString != nil)
        #expect(jsonString?.contains("Test Burger") == true)
        #expect(jsonString?.contains("9.99") == true)
    }
    
    @Test("FoodItem decoding from JSON")
    func testFoodItemDecoding() throws {
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
        
        let decoder = JSONDecoder()
        let foodItem = try decoder.decode(FoodItem.self, from: data)
        
        #expect(foodItem.id == 1)
        #expect(foodItem.name == "Test Burger")
        #expect(foodItem.description == "A delicious test burger")
        #expect(foodItem.price == 9.99)
        #expect(foodItem.imageUrl == "https://example.com/image.jpg")
        #expect(foodItem.category == "Burgers")
    }
    
    @Test("FoodItem formatted price calculation", arguments: [
        (9.99, "$9.99"),
        (10.0, "$10.00"),
        (0.0, "$0.00"),
        (123.45, "$123.45")
    ])
    func testFoodItemFormattedPrice(price: Double, expected: String) {
        let foodItem = FoodItem(
            id: 1,
            name: "Test Item",
            description: "Test",
            price: price,
            imageUrl: "https://example.com/image.jpg",
            category: "Test"
        )
        
        #expect(foodItem.formattedPrice == expected)
    }
    
    @Test("FoodItem hashable implementation")
    func testFoodItemHashable() {
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
        
        #expect(foodItem1.hashValue == foodItem2.hashValue)
        #expect(foodItem1.hashValue != foodItem3.hashValue)
    }
    
    @Test("FoodItemsResponse decoding from JSON")
    func testFoodItemsResponseDecoding() throws {
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
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(FoodItemsResponse.self, from: data)
        
        #expect(response.foodItems.count == 1)
        #expect(response.foodItems.first?.name == "Test Burger")
    }
    
    @Test("FoodLoadingState equality comparison")
    func testFoodLoadingStateEquality() {
        #expect(FoodLoadingState.idle == FoodLoadingState.idle)
        #expect(FoodLoadingState.loading == FoodLoadingState.loading)
        #expect(FoodLoadingState.loaded([]) == FoodLoadingState.loaded([]))
        #expect(FoodLoadingState.error("test") == FoodLoadingState.error("test"))
        #expect(FoodLoadingState.error("test1") != FoodLoadingState.error("test2"))
    }
}
