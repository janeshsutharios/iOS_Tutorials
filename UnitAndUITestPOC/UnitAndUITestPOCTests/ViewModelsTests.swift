//
//  ViewModelsTests.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import XCTest
@testable import UnitAndUITestPOC

@MainActor
final class ViewModelsTests: XCTestCase {
    
    // MARK: - LoginViewModel Tests
    
    func testLoginViewModelInitialization() {
        let mockAuthService = MockAuthService()
        let viewModel = LoginViewModel(authService: mockAuthService)
        
        XCTAssertEqual(viewModel.username, "test")
        XCTAssertEqual(viewModel.password, "password")
        XCTAssertEqual(viewModel.authState, .idle)
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertTrue(viewModel.accessToken.isEmpty)
    }
    
    func testLoginViewModelIsLoadingWhenIdle() {
        let mockAuthService = MockAuthService()
        let viewModel = LoginViewModel(authService: mockAuthService)
        
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLoginViewModelIsLoadingWhenLoading() {
        let mockAuthService = MockAuthService()
        let viewModel = LoginViewModel(authService: mockAuthService)
        
        // Set loading state
        viewModel.authState = .loading
        
        XCTAssertTrue(viewModel.isLoading)
    }
    
    func testLoginViewModelErrorMessageWhenIdle() {
        let mockAuthService = MockAuthService()
        let viewModel = LoginViewModel(authService: mockAuthService)
        
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoginViewModelErrorMessageWhenError() {
        let mockAuthService = MockAuthService()
        let viewModel = LoginViewModel(authService: mockAuthService)
        
        viewModel.authState = .error("Test error message")
        
        XCTAssertEqual(viewModel.errorMessage, "Test error message")
    }
    
    func testLoginViewModelLoginSuccess() async {
        let mockAuthService = MockAuthService()
        let expectedResponse = LoginResponse(accessToken: "test-access-token", refreshToken: "test-refresh-token")
        await mockAuthService.setMockResponse(expectedResponse)
        
        let viewModel = LoginViewModel(authService: mockAuthService)
        viewModel.username = "testuser"
        viewModel.password = "testpass"
        
        await viewModel.login()
        
        XCTAssertEqual(viewModel.authState, .authenticated)
        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertEqual(viewModel.accessToken, "test-access-token")
    }
    
    func testLoginViewModelLoginWithEmptyCredentials() async {
        let mockAuthService = MockAuthService()
        let viewModel = LoginViewModel(authService: mockAuthService)
        viewModel.username = ""
        viewModel.password = ""
        
        await viewModel.login()
        
        XCTAssertEqual(viewModel.authState, .error("Please enter both username and password"))
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertTrue(viewModel.accessToken.isEmpty)
    }
    
    func testLoginViewModelLoginWithEmptyUsername() async {
        let mockAuthService = MockAuthService()
        let viewModel = LoginViewModel(authService: mockAuthService)
        viewModel.username = ""
        viewModel.password = "testpass"
        
        await viewModel.login()
        
        XCTAssertEqual(viewModel.authState, .error("Please enter both username and password"))
        XCTAssertFalse(viewModel.isAuthenticated)
    }
    
    func testLoginViewModelLoginWithEmptyPassword() async {
        let mockAuthService = MockAuthService()
        let viewModel = LoginViewModel(authService: mockAuthService)
        viewModel.username = "testuser"
        viewModel.password = ""
        
        await viewModel.login()
        
        XCTAssertEqual(viewModel.authState, .error("Please enter both username and password"))
        XCTAssertFalse(viewModel.isAuthenticated)
    }
    
    func testLoginViewModelLoginWithNetworkError() async {
        let mockAuthService = MockAuthService()
        await mockAuthService.setMockError(NetworkError.unauthorized)
        
        let viewModel = LoginViewModel(authService: mockAuthService)
        viewModel.username = "testuser"
        viewModel.password = "testpass"
        
        await viewModel.login()
        
        XCTAssertEqual(viewModel.authState, .error("Unauthorized access"))
        XCTAssertFalse(viewModel.isAuthenticated)
    }
    
    func testLoginViewModelLoginWithServerError() async {
        let mockAuthService = MockAuthService()
        await mockAuthService.setMockError(NetworkError.serverError(500))
        
        let viewModel = LoginViewModel(authService: mockAuthService)
        viewModel.username = "testuser"
        viewModel.password = "testpass"
        
        await viewModel.login()
        
        XCTAssertEqual(viewModel.authState, .error("Server error with code: 500"))
        XCTAssertFalse(viewModel.isAuthenticated)
    }
    
    func testLoginViewModelLoginWithUnexpectedError() async {
        let mockAuthService = MockAuthService()
        await mockAuthService.setMockError(NSError(domain: "TestDomain", code: 123, userInfo: nil))
        
        let viewModel = LoginViewModel(authService: mockAuthService)
        viewModel.username = "testuser"
        viewModel.password = "testpass"
        
        await viewModel.login()
        
        XCTAssertEqual(viewModel.authState, .error("An unexpected error occurred"))
        XCTAssertFalse(viewModel.isAuthenticated)
    }
    
    func testLoginViewModelResetState() {
        let mockAuthService = MockAuthService()
        let viewModel = LoginViewModel(authService: mockAuthService)
        
        // Set some state
        viewModel.authState = .authenticated
        viewModel.username = "testuser"
        viewModel.password = "testpass"
        viewModel.isAuthenticated = true
        viewModel.accessToken = "test-token"
        
        viewModel.resetState()
        
        XCTAssertEqual(viewModel.authState, .idle)
        XCTAssertTrue(viewModel.username.isEmpty)
        XCTAssertTrue(viewModel.password.isEmpty)
    }
    
    // MARK: - FoodViewModel Tests
    
    func testFoodViewModelInitialization() {
        let mockFoodService = MockFoodService()
        let viewModel = FoodViewModel(foodService: mockFoodService)
        
        XCTAssertEqual(viewModel.foodState, .idle)
    }
    
    func testFoodViewModelIsLoadingWhenIdle() {
        let mockFoodService = MockFoodService()
        let viewModel = FoodViewModel(foodService: mockFoodService)
        
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testFoodViewModelIsLoadingWhenLoading() {
        let mockFoodService = MockFoodService()
        let viewModel = FoodViewModel(foodService: mockFoodService)
        
        viewModel.foodState = .loading
        
        XCTAssertTrue(viewModel.isLoading)
    }
    
    func testFoodViewModelFoodItemsWhenIdle() {
        let mockFoodService = MockFoodService()
        let viewModel = FoodViewModel(foodService: mockFoodService)
        
        XCTAssertTrue(viewModel.foodItems.isEmpty)
    }
    
    func testFoodViewModelFoodItemsWhenLoaded() {
        let mockFoodService = MockFoodService()
        let viewModel = FoodViewModel(foodService: mockFoodService)
        
        let foodItems = [
            FoodItem(id: 1, name: "Pizza", description: "Delicious pizza", price: 12.99, imageUrl: "https://example.com/pizza.jpg", category: "Italian"),
            FoodItem(id: 2, name: "Burger", description: "Delicious burger", price: 8.99, imageUrl: "https://example.com/burger.jpg", category: "American")
        ]
        
        viewModel.foodState = .loaded(foodItems)
        
        XCTAssertEqual(viewModel.foodItems.count, 2)
        XCTAssertEqual(viewModel.foodItems[0].name, "Pizza")
        XCTAssertEqual(viewModel.foodItems[1].name, "Burger")
    }
    
    func testFoodViewModelErrorMessageWhenIdle() {
        let mockFoodService = MockFoodService()
        let viewModel = FoodViewModel(foodService: mockFoodService)
        
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFoodViewModelErrorMessageWhenError() {
        let mockFoodService = MockFoodService()
        let viewModel = FoodViewModel(foodService: mockFoodService)
        
        viewModel.foodState = .error("Test error message")
        
        XCTAssertEqual(viewModel.errorMessage, "Test error message")
    }
    
    func testFoodViewModelFetchFoodItemsSuccess() async {
        let mockFoodService = MockFoodService()
        let expectedFoodItems = [
            FoodItem(id: 1, name: "Pizza", description: "Delicious pizza", price: 12.99, imageUrl: "https://example.com/pizza.jpg", category: "Italian"),
            FoodItem(id: 2, name: "Burger", description: "Delicious burger", price: 8.99, imageUrl: "https://example.com/burger.jpg", category: "American")
        ]
        await mockFoodService.setMockFoodItems(expectedFoodItems)
        
        let viewModel = FoodViewModel(foodService: mockFoodService)
        
        await viewModel.fetchFoodItems(token: "test-token")
        
        XCTAssertEqual(viewModel.foodState, .loaded(expectedFoodItems))
        XCTAssertEqual(viewModel.foodItems.count, 2)
        XCTAssertEqual(viewModel.foodItems[0].name, "Pizza")
        XCTAssertEqual(viewModel.foodItems[1].name, "Burger")
    }
    
    func testFoodViewModelFetchFoodItemsWithEmptyToken() async {
        let mockFoodService = MockFoodService()
        let viewModel = FoodViewModel(foodService: mockFoodService)
        
        await viewModel.fetchFoodItems(token: "")
        
        XCTAssertEqual(viewModel.foodState, .error("Invalid token"))
        XCTAssertTrue(viewModel.foodItems.isEmpty)
    }
    
    func testFoodViewModelFetchFoodItemsWithNetworkError() async {
        let mockFoodService = MockFoodService()
        await mockFoodService.setMockError(NetworkError.unauthorized)
        
        let viewModel = FoodViewModel(foodService: mockFoodService)
        
        await viewModel.fetchFoodItems(token: "test-token")
        
        XCTAssertEqual(viewModel.foodState, .error("Unauthorized access"))
        XCTAssertTrue(viewModel.foodItems.isEmpty)
    }
    
    func testFoodViewModelFetchFoodItemsWithServerError() async {
        let mockFoodService = MockFoodService()
        await mockFoodService.setMockError(NetworkError.serverError(500))
        
        let viewModel = FoodViewModel(foodService: mockFoodService)
        
        await viewModel.fetchFoodItems(token: "test-token")
        
        XCTAssertEqual(viewModel.foodState, .error("Server error with code: 500"))
        XCTAssertTrue(viewModel.foodItems.isEmpty)
    }
    
    func testFoodViewModelFetchFoodItemsWithUnexpectedError() async {
        let mockFoodService = MockFoodService()
        await mockFoodService.setMockError(NSError(domain: "TestDomain", code: 123, userInfo: nil))
        
        let viewModel = FoodViewModel(foodService: mockFoodService)
        
        await viewModel.fetchFoodItems(token: "test-token")
        
        XCTAssertEqual(viewModel.foodState, .error("An unexpected error occurred"))
        XCTAssertTrue(viewModel.foodItems.isEmpty)
    }
    
    func testFoodViewModelResetState() {
        let mockFoodService = MockFoodService()
        let viewModel = FoodViewModel(foodService: mockFoodService)
        
        let foodItems = [
            FoodItem(id: 1, name: "Pizza", description: "Delicious pizza", price: 12.99, imageUrl: "https://example.com/pizza.jpg", category: "Italian")
        ]
        
        viewModel.foodState = .loaded(foodItems)
        
        viewModel.resetState()
        
        XCTAssertEqual(viewModel.foodState, .idle)
        XCTAssertTrue(viewModel.foodItems.isEmpty)
    }
}

// MARK: - Mock Services

actor MockAuthService: AuthServiceProtocol {
    var mockResponse: LoginResponse?
    var mockError: Error?
    
    func login(username: String, password: String) async throws -> LoginResponse {
        if let error = mockError {
            throw error
        }
        
        guard let response = mockResponse else {
            throw NetworkError.unknown
        }
        
        return response
    }
    
    func setMockResponse(_ response: LoginResponse?) async {
        self.mockResponse = response
    }
    
    func setMockError(_ error: Error?) async {
        self.mockError = error
    }
}

actor MockFoodService: FoodServiceProtocol {
    var mockFoodItems: [FoodItem] = []
    var mockError: Error?
    
    func fetchFoodItems(token: String) async throws -> [FoodItem] {
        if let error = mockError {
            throw error
        }
        
        return mockFoodItems
    }
    
    func setMockFoodItems(_ items: [FoodItem]) async {
        self.mockFoodItems = items
    }
    
    func setMockError(_ error: Error?) async {
        self.mockError = error
    }
    
}
