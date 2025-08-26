//
//  ModelsTests.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import XCTest
@testable import UnitAndUITestPOC

@MainActor
final class ModelsTests: XCTestCase {
    
    // MARK: - LoginRequest Tests
    
    func testLoginRequestInitialization() {
        let request = LoginRequest(username: "testuser", password: "testpass")
        
        XCTAssertEqual(request.username, "testuser")
        XCTAssertEqual(request.password, "testpass")
    }
    
    func testLoginRequestCoding() throws {
        let originalRequest = LoginRequest(username: "testuser", password: "testpass")
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalRequest)
        
        let decoder = JSONDecoder()
        let decodedRequest = try decoder.decode(LoginRequest.self, from: data)
        
        XCTAssertEqual(originalRequest.username, decodedRequest.username)
        XCTAssertEqual(originalRequest.password, decodedRequest.password)
    }
    
    // MARK: - LoginResponse Tests
    
    func testLoginResponseInitialization() {
        let response = LoginResponse(accessToken: "access123", refreshToken: "refresh456")
        
        XCTAssertEqual(response.accessToken, "access123")
        XCTAssertEqual(response.refreshToken, "refresh456")
    }
    
    func testLoginResponseCoding() throws {
        let originalResponse = LoginResponse(accessToken: "access123", refreshToken: "refresh456")
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalResponse)
        
        let decoder = JSONDecoder()
        let decodedResponse = try decoder.decode(LoginResponse.self, from: data)
        
        XCTAssertEqual(originalResponse.accessToken, decodedResponse.accessToken)
        XCTAssertEqual(originalResponse.refreshToken, decodedResponse.refreshToken)
    }
    
    func testLoginResponseFromJSON() throws {
        let jsonString = """
        {
            "accessToken": "access123",
            "refreshToken": "refresh456"
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        let response = try JSONDecoder().decode(LoginResponse.self, from: data)
        
        XCTAssertEqual(response.accessToken, "access123")
        XCTAssertEqual(response.refreshToken, "refresh456")
    }
    
    // MARK: - AuthState Tests
    
    func testAuthStateEquality() {
        XCTAssertEqual(AuthState.idle, AuthState.idle)
        XCTAssertEqual(AuthState.loading, AuthState.loading)
        XCTAssertEqual(AuthState.authenticated, AuthState.authenticated)
        XCTAssertEqual(AuthState.error("test"), AuthState.error("test"))
        
        XCTAssertNotEqual(AuthState.idle, AuthState.loading)
        XCTAssertNotEqual(AuthState.error("test1"), AuthState.error("test2"))
    }
    
    // MARK: - FoodItem Tests
    
    func testFoodItemInitialization() {
        let foodItem = FoodItem(
            id: 1,
            name: "Pizza",
            description: "Delicious pizza",
            price: 12.99,
            imageUrl: "https://example.com/pizza.jpg",
            category: "Italian"
        )
        
        XCTAssertEqual(foodItem.id, 1)
        XCTAssertEqual(foodItem.name, "Pizza")
        XCTAssertEqual(foodItem.description, "Delicious pizza")
        XCTAssertEqual(foodItem.price, 12.99)
        XCTAssertEqual(foodItem.imageUrl, "https://example.com/pizza.jpg")
        XCTAssertEqual(foodItem.category, "Italian")
    }
    
    func testFoodItemFormattedPrice() {
        let foodItem = FoodItem(
            id: 1,
            name: "Pizza",
            description: "Delicious pizza",
            price: 12.99,
            imageUrl: "https://example.com/pizza.jpg",
            category: "Italian"
        )
        
        XCTAssertEqual(foodItem.formattedPrice, "$12.99")
    }
    
    func testFoodItemFormattedPriceWithZero() {
        let foodItem = FoodItem(
            id: 1,
            name: "Free Item",
            description: "Free item",
            price: 0.0,
            imageUrl: "https://example.com/free.jpg",
            category: "Free"
        )
        
        XCTAssertEqual(foodItem.formattedPrice, "$0.00")
    }
    
    func testFoodItemCoding() throws {
        let originalFoodItem = FoodItem(
            id: 1,
            name: "Pizza",
            description: "Delicious pizza",
            price: 12.99,
            imageUrl: "https://example.com/pizza.jpg",
            category: "Italian"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalFoodItem)
        
        let decoder = JSONDecoder()
        let decodedFoodItem = try decoder.decode(FoodItem.self, from: data)
        
        XCTAssertEqual(originalFoodItem.id, decodedFoodItem.id)
        XCTAssertEqual(originalFoodItem.name, decodedFoodItem.name)
        XCTAssertEqual(originalFoodItem.description, decodedFoodItem.description)
        XCTAssertEqual(originalFoodItem.price, decodedFoodItem.price)
        XCTAssertEqual(originalFoodItem.imageUrl, decodedFoodItem.imageUrl)
        XCTAssertEqual(originalFoodItem.category, decodedFoodItem.category)
    }
    
    func testFoodItemFromJSON() throws {
        let jsonString = """
        {
            "id": 1,
            "name": "Pizza",
            "description": "Delicious pizza",
            "price": 12.99,
            "imageUrl": "https://example.com/pizza.jpg",
            "category": "Italian"
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        let foodItem = try JSONDecoder().decode(FoodItem.self, from: data)
        
        XCTAssertEqual(foodItem.id, 1)
        XCTAssertEqual(foodItem.name, "Pizza")
        XCTAssertEqual(foodItem.description, "Delicious pizza")
        XCTAssertEqual(foodItem.price, 12.99)
        XCTAssertEqual(foodItem.imageUrl, "https://example.com/pizza.jpg")
        XCTAssertEqual(foodItem.category, "Italian")
    }
    
    func testFoodItemHashable() {
        let foodItem1 = FoodItem(
            id: 1,
            name: "Pizza",
            description: "Delicious pizza",
            price: 12.99,
            imageUrl: "https://example.com/pizza.jpg",
            category: "Italian"
        )
        
        let foodItem2 = FoodItem(
            id: 1,
            name: "Pizza",
            description: "Delicious pizza",
            price: 12.99,
            imageUrl: "https://example.com/pizza.jpg",
            category: "Italian"
        )
        
        let foodItem3 = FoodItem(
            id: 2,
            name: "Burger",
            description: "Delicious burger",
            price: 8.99,
            imageUrl: "https://example.com/burger.jpg",
            category: "American"
        )
        
        XCTAssertEqual(foodItem1.hashValue, foodItem2.hashValue)
        XCTAssertNotEqual(foodItem1.hashValue, foodItem3.hashValue)
    }
    
    // MARK: - FoodItemsResponse Tests
    
    func testFoodItemsResponseInitialization() {
        let foodItems = [
            FoodItem(id: 1, name: "Pizza", description: "Delicious pizza", price: 12.99, imageUrl: "https://example.com/pizza.jpg", category: "Italian"),
            FoodItem(id: 2, name: "Burger", description: "Delicious burger", price: 8.99, imageUrl: "https://example.com/burger.jpg", category: "American")
        ]
        
        let response = FoodItemsResponse(foodItems: foodItems)
        
        XCTAssertEqual(response.foodItems.count, 2)
        XCTAssertEqual(response.foodItems[0].name, "Pizza")
        XCTAssertEqual(response.foodItems[1].name, "Burger")
    }
    
    func testFoodItemsResponseCoding() throws {
        let foodItems = [
            FoodItem(id: 1, name: "Pizza", description: "Delicious pizza", price: 12.99, imageUrl: "https://example.com/pizza.jpg", category: "Italian"),
            FoodItem(id: 2, name: "Burger", description: "Delicious burger", price: 8.99, imageUrl: "https://example.com/burger.jpg", category: "American")
        ]
        
        let originalResponse = FoodItemsResponse(foodItems: foodItems)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalResponse)
        
        let decoder = JSONDecoder()
        let decodedResponse = try decoder.decode(FoodItemsResponse.self, from: data)
        
        XCTAssertEqual(originalResponse.foodItems.count, decodedResponse.foodItems.count)
        XCTAssertEqual(originalResponse.foodItems[0].name, decodedResponse.foodItems[0].name)
        XCTAssertEqual(originalResponse.foodItems[1].name, decodedResponse.foodItems[1].name)
    }
    
    func testFoodItemsResponseFromJSON() throws {
        let jsonString = """
        {
            "foodItems": [
                {
                    "id": 1,
                    "name": "Pizza",
                    "description": "Delicious pizza",
                    "price": 12.99,
                    "imageUrl": "https://example.com/pizza.jpg",
                    "category": "Italian"
                },
                {
                    "id": 2,
                    "name": "Burger",
                    "description": "Delicious burger",
                    "price": 8.99,
                    "imageUrl": "https://example.com/burger.jpg",
                    "category": "American"
                }
            ]
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        let response = try JSONDecoder().decode(FoodItemsResponse.self, from: data)
        
        XCTAssertEqual(response.foodItems.count, 2)
        XCTAssertEqual(response.foodItems[0].name, "Pizza")
        XCTAssertEqual(response.foodItems[1].name, "Burger")
    }
    
    // MARK: - FoodLoadingState Tests
    
    func testFoodLoadingStateEquality() {
        let foodItems = [
            FoodItem(id: 1, name: "Pizza", description: "Delicious pizza", price: 12.99, imageUrl: "https://example.com/pizza.jpg", category: "Italian")
        ]
        
        XCTAssertEqual(FoodLoadingState.idle, FoodLoadingState.idle)
        XCTAssertEqual(FoodLoadingState.loading, FoodLoadingState.loading)
        XCTAssertEqual(FoodLoadingState.loaded(foodItems), FoodLoadingState.loaded(foodItems))
        XCTAssertEqual(FoodLoadingState.error("test"), FoodLoadingState.error("test"))
        
        XCTAssertNotEqual(FoodLoadingState.idle, FoodLoadingState.loading)
        XCTAssertNotEqual(FoodLoadingState.error("test1"), FoodLoadingState.error("test2"))
    }
}
