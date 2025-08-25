//
//  ServicesSwiftTests.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import Testing
@testable import UnitAndUITestPOC

@Suite("Services")
struct ServicesSwiftTests {
    
    @Test("AuthService login success")
    func testAuthServiceLoginSuccess() async throws {
        let mockNetworkService = MockNetworkService()
        let expectedResponse = LoginResponse(
            accessToken: "test-access-token",
            refreshToken: "test-refresh-token"
        )
        mockNetworkService.mockResponse = expectedResponse
        
        let authService = AuthService(networkService: mockNetworkService)
        let result = try await authService.login(username: "testuser", password: "testpass")
        
        #expect(result.accessToken == "test-access-token")
        #expect(result.refreshToken == "test-refresh-token")
        #expect(mockNetworkService.requestCallCount == 1)
        
        // Verify the endpoint was called correctly
        if case .login(let request) = mockNetworkService.lastEndpoint {
            #expect(request.username == "testuser")
            #expect(request.password == "testpass")
        } else {
            #expect(false, "Expected login endpoint to be called")
        }
    }
    
    @Test("AuthService login failure")
    func testAuthServiceLoginFailure() async {
        let mockNetworkService = MockNetworkService()
        mockNetworkService.shouldSucceed = false
        mockNetworkService.mockError = NetworkError.unauthorized
        
        let authService = AuthService(networkService: mockNetworkService)
        
        do {
            _ = try await authService.login(username: "testuser", password: "testpass")
            #expect(false, "Expected login to fail")
        } catch let error as NetworkError {
            #expect(error == NetworkError.unauthorized)
        } catch {
            #expect(false, "Expected NetworkError but got \(error)")
        }
    }
    
    @Test("FoodService fetchFoodItems success")
    func testFoodServiceFetchFoodItemsSuccess() async throws {
        let mockNetworkService = MockNetworkService()
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
        
        let foodService = FoodService(networkService: mockNetworkService)
        let result = try await foodService.fetchFoodItems(token: "test-token")
        
        #expect(result.count == 2)
        #expect(result[0].name == "Test Burger")
        #expect(result[1].name == "Test Pizza")
        #expect(mockNetworkService.requestCallCount == 1)
        
        // Verify the endpoint was called correctly
        if case .foodItems(let token) = mockNetworkService.lastEndpoint {
            #expect(token == "test-token")
        } else {
            #expect(false, "Expected foodItems endpoint to be called")
        }
    }
    
    @Test("FoodService fetchFoodItems failure")
    func testFoodServiceFetchFoodItemsFailure() async {
        let mockNetworkService = MockNetworkService()
        mockNetworkService.shouldSucceed = false
        mockNetworkService.mockError = NetworkError.unauthorized
        
        let foodService = FoodService(networkService: mockNetworkService)
        
        do {
            _ = try await foodService.fetchFoodItems(token: "test-token")
            #expect(false, "Expected fetch to fail")
        } catch let error as NetworkError {
            #expect(error == NetworkError.unauthorized)
        } catch {
            #expect(false, "Expected NetworkError but got \(error)")
        }
    }
    
    @Test("FoodService fetchFoodItems empty response")
    func testFoodServiceFetchFoodItemsEmptyResponse() async throws {
        let mockNetworkService = MockNetworkService()
        let expectedResponse = FoodItemsResponse(foodItems: [])
        mockNetworkService.mockResponse = expectedResponse
        
        let foodService = FoodService(networkService: mockNetworkService)
        let result = try await foodService.fetchFoodItems(token: "test-token")
        
        #expect(result.isEmpty)
        #expect(mockNetworkService.requestCallCount == 1)
    }
}
