//
//  FoodServiceTests.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import XCTest
@testable import UnitAndUITestPOC

final class FoodServiceTests: XCTestCase {
    var mockNetworkService: MockNetworkService!
    var foodService: FoodService!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        foodService = FoodService(networkService: mockNetworkService)
    }
    
    override func tearDown() {
        mockNetworkService.reset()
        mockNetworkService = nil
        foodService = nil
        super.tearDown()
    }
    
    func testFetchFoodItemsSuccess() async throws {
        // Given
        let expectedFoodItems = [
            FoodItem(
                id: 1,
                name: "Test Burger",
                description: "A delicious test burger",
                price: 9.99,
                imageUrl: "https://example.com/image.jpg",
                category: "Burgers"
            ),
            FoodItem(
                id: 2,
                name: "Test Pizza",
                description: "A delicious test pizza",
                price: 12.99,
                imageUrl: "https://example.com/pizza.jpg",
                category: "Pizza"
            )
        ]
        let expectedResponse = FoodItemsResponse(foodItems: expectedFoodItems)
        mockNetworkService.mockResponse = expectedResponse
        
        // When
        let result = try await foodService.fetchFoodItems(token: "test-token")
        
        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].name, "Test Burger")
        XCTAssertEqual(result[1].name, "Test Pizza")
        XCTAssertEqual(mockNetworkService.requestCallCount, 1)
        
        // Verify the endpoint was called correctly
        if case .foodItems(let token) = mockNetworkService.lastEndpoint {
            XCTAssertEqual(token, "test-token")
        } else {
            XCTFail("Expected foodItems endpoint to be called")
        }
    }
    
    func testFetchFoodItemsFailure() async {
        // Given
        mockNetworkService.shouldSucceed = false
        mockNetworkService.mockError = NetworkError.unauthorized
        
        // When & Then
        do {
            _ = try await foodService.fetchFoodItems(token: "test-token")
            XCTFail("Expected fetch to fail")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.unauthorized)
        } catch {
            XCTFail("Expected NetworkError but got \(error)")
        }
    }
    
    func testFetchFoodItemsWithServerError() async {
        // Given
        mockNetworkService.shouldSucceed = false
        mockNetworkService.mockError = NetworkError.serverError(500)
        
        // When & Then
        do {
            _ = try await foodService.fetchFoodItems(token: "test-token")
            XCTFail("Expected fetch to fail")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.serverError(500))
        } catch {
            XCTFail("Expected NetworkError but got \(error)")
        }
    }
    
    func testFetchFoodItemsEmptyResponse() async throws {
        // Given
        let expectedResponse = FoodItemsResponse(foodItems: [])
        mockNetworkService.mockResponse = expectedResponse
        
        // When
        let result = try await foodService.fetchFoodItems(token: "test-token")
        
        // Then
        XCTAssertTrue(result.isEmpty)
        XCTAssertEqual(mockNetworkService.requestCallCount, 1)
    }
}
