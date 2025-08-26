//
//  ServicesTests.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import XCTest
@testable import UnitAndUITestPOC

@MainActor
final class ServicesTests: XCTestCase {
    
    // MARK: - AuthService Tests
    
    func testAuthServiceInitialization() {
        let mockNetworkService = MockNetworkService()
        let authService = AuthService(networkService: mockNetworkService)
        
        XCTAssertNotNil(authService)
    }
    
    func testAuthServiceLoginSuccess() async throws {
        let expectedResponse = LoginResponse(accessToken: "test-access-token", refreshToken: "test-refresh-token")
        let mockNetworkService = MockNetworkService()
        await mockNetworkService.setMockResponse(expectedResponse)
        
        let authService = AuthService(networkService: mockNetworkService)
        
        let response = try await authService.login(username: "testuser", password: "testpass")
        
        XCTAssertEqual(response.accessToken, "test-access-token")
        XCTAssertEqual(response.refreshToken, "test-refresh-token")
        
        // Verify the network service was called with correct endpoint
        let endpoint = await mockNetworkService.getLastEndpoint()
        XCTAssertEqual(endpoint?.path, "/login")
        
        XCTAssertEqual(endpoint?.method, .POST)
    }
    
    func testAuthServiceLoginFailure() async {
        let mockNetworkService = MockNetworkService()
        await mockNetworkService.setMockError(NetworkError.unauthorized)
        
        let authService = AuthService(networkService: mockNetworkService)
        
        do {
            let _ = try await authService.login(username: "testuser", password: "testpass")
            XCTFail("Expected NetworkError.unauthorized but no error was thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.unauthorized)
        } catch {
            XCTFail("Expected NetworkError but got \(error)")
        }
    }
    
    func testAuthServiceLoginWithNetworkError() async {
        let mockNetworkService = MockNetworkService()
        await mockNetworkService.setMockError(NetworkError.serverError(500))
        
        let authService = AuthService(networkService: mockNetworkService)
        
        do {
            let _ = try await authService.login(username: "testuser", password: "testpass")
            XCTFail("Expected NetworkError.serverError but no error was thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.serverError(500))
        } catch {
            XCTFail("Expected NetworkError but got \(error)")
        }
    }
    
    // MARK: - FoodService Tests
    
    func testFoodServiceInitialization() {
        let mockNetworkService = MockNetworkService()
        let foodService = FoodService(networkService: mockNetworkService)
        
        XCTAssertNotNil(foodService)
    }
    
    func testFoodServiceFetchFoodItemsSuccess() async throws {
        let expectedFoodItems = [
            FoodItem(id: 1, name: "Pizza", description: "Delicious pizza", price: 12.99, imageUrl: "https://example.com/pizza.jpg", category: "Italian"),
            FoodItem(id: 2, name: "Burger", description: "Delicious burger", price: 8.99, imageUrl: "https://example.com/burger.jpg", category: "American")
        ]
        
        let mockResponse = FoodItemsResponse(foodItems: expectedFoodItems)
        let mockNetworkService = MockNetworkService()
        await mockNetworkService.setMockResponse(mockResponse)
        
        let foodService = FoodService(networkService: mockNetworkService)
        
        let foodItems = try await foodService.fetchFoodItems(token: "test-token")
        
        XCTAssertEqual(foodItems.count, 2)
        XCTAssertEqual(foodItems[0].name, "Pizza")
        XCTAssertEqual(foodItems[1].name, "Burger")
        
        // Verify the network service was called with correct endpoint
        let endpoint = await mockNetworkService.getLastEndpoint()

        XCTAssertEqual(endpoint?.path, "/food-items")
        XCTAssertEqual(endpoint?.method, .GET)
    }
    
    func testFoodServiceFetchFoodItemsFailure() async {
        let mockNetworkService = MockNetworkService()
        await mockNetworkService.setMockError(NetworkError.unauthorized)
        
        let foodService = FoodService(networkService: mockNetworkService)
        
        do {
            let _ = try await foodService.fetchFoodItems(token: "test-token")
            XCTFail("Expected NetworkError.unauthorized but no error was thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.unauthorized)
        } catch {
            XCTFail("Expected NetworkError but got \(error)")
        }
    }
    
    func testFoodServiceFetchFoodItemsWithDecodingError() async {
        let mockNetworkService = MockNetworkService()
        await mockNetworkService.setMockError( NetworkError.decodingError)
        
        let foodService = FoodService(networkService: mockNetworkService)
        
        do {
            let _ = try await foodService.fetchFoodItems(token: "test-token")
            XCTFail("Expected NetworkError.decodingError but no error was thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.decodingError)
        } catch {
            XCTFail("Expected NetworkError but got \(error)")
        }
    }
    
    func testFoodServiceFetchFoodItemsWithServerError() async {
        let mockNetworkService = MockNetworkService()
        await mockNetworkService.setMockError(NetworkError.serverError(500))
        
        let foodService = FoodService(networkService: mockNetworkService)
        
        do {
            let _ = try await foodService.fetchFoodItems(token: "test-token")
            XCTFail("Expected NetworkError.serverError but no error was thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.serverError(500))
        } catch {
            XCTFail("Expected NetworkError but got \(error)")
        }
    }
}

// MARK: - Mock NetworkService

actor MockNetworkService: NetworkServiceProtocol {
    private var mockResponse: Any?
    private var mockError: Error?
    private var lastEndpoint: APIEndpoint?
    
    func request<T: Codable & Sendable>(_ endpoint: APIEndpoint) async throws -> T {
        lastEndpoint = endpoint
        
        if let error = mockError {
            throw error
        }
        
        guard let response = mockResponse as? T else {
            throw NetworkError.unknown
        }
        
        return response
    }
    
    func setMockResponse<T: Codable & Sendable>(_ response: T) async {
        self.mockResponse = response
    }
    
    func setMockError(_ error: Error) async {
        self.mockError = error
    }
    
    func setEndpoint(_ endpoint: APIEndpoint) async {
        self.lastEndpoint = endpoint
    }
    
    // ✅ Safe async getters
    func getMockResponse<T: Codable & Sendable>() async -> T? {
        return mockResponse as? T
    }
    
    func getMockError() async -> Error? {
        return mockError
    }
    
    func getLastEndpoint() async -> APIEndpoint? {
        return lastEndpoint
    }
}
