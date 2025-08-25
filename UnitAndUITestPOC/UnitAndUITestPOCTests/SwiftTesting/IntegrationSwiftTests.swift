//
//  IntegrationSwiftTests.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import Testing
@testable import UnitAndUITestPOC

@Suite("Integration Tests")
struct IntegrationSwiftTests {
    
    @Test("Complete login to food flow")
    func testLoginToFoodFlow() async {
        let mockNetworkService = MockNetworkService()
        
        // Mock login response
        let loginResponse = LoginResponse(
            accessToken: "test-access-token",
            refreshToken: "test-refresh-token"
        )
        mockNetworkService.mockResponse = loginResponse
        
        // Mock food items response
        let foodItems = [
            FoodItem(
                id: 1,
                name: "Test Burger",
                description: "A delicious test burger",
                price: 9.99,
                imageUrl: "https://example.com/image.jpg",
                category: "Burgers"
            )
        ]
        let foodResponse = FoodItemsResponse(foodItems: foodItems)
        mockNetworkService.mockResponse = foodResponse
        
        let authService = AuthService(networkService: mockNetworkService)
        let foodService = FoodService(networkService: mockNetworkService)
        let loginViewModel = LoginViewModel(authService: authService)
        let foodViewModel = FoodViewModel(foodService: foodService)
        
        // Test login
        loginViewModel.username = "test"
        loginViewModel.password = "password"
        
        await loginViewModel.login()
        
        #expect(loginViewModel.isAuthenticated == true)
        #expect(loginViewModel.accessToken == "test-access-token")
        
        // Test food fetching with the token
        await foodViewModel.fetchFoodItems(token: loginViewModel.accessToken)
        
        if case .loaded(let items) = foodViewModel.foodState {
            #expect(items.count == 1)
            #expect(items.first?.name == "Test Burger")
        } else {
            #expect(false, "Expected food items to be loaded")
        }
    }
    
    @Test("Service dependency injection")
    func testServiceDependencyInjection() {
        // Test that services can be injected with different network services
        let mockNetworkService = MockNetworkService()
        let authServiceWithMock = AuthService(networkService: mockNetworkService)
        let foodServiceWithMock = FoodService(networkService: mockNetworkService)
        
        #expect(authServiceWithMock != nil)
        #expect(foodServiceWithMock != nil)
    }
    
    @Test("ViewModel dependency injection")
    func testViewModelDependencyInjection() {
        // Test that view models can be injected with different services
        let mockAuthService = MockAuthService()
        let mockFoodService = MockFoodService()
        
        let loginViewModelWithMock = LoginViewModel(authService: mockAuthService)
        let foodViewModelWithMock = FoodViewModel(foodService: mockFoodService)
        
        #expect(loginViewModelWithMock != nil)
        #expect(foodViewModelWithMock != nil)
    }
    
    @Test("Error propagation through system")
    func testErrorPropagation() async {
        let mockNetworkService = MockNetworkService()
        mockNetworkService.shouldSucceed = false
        mockNetworkService.mockError = NetworkError.unauthorized
        
        let authServiceWithMock = AuthService(networkService: mockNetworkService)
        let loginViewModelWithMock = LoginViewModel(authService: authServiceWithMock)
        
        loginViewModelWithMock.username = "test"
        loginViewModelWithMock.password = "password"
        
        await loginViewModelWithMock.login()
        
        if case .error(let message) = loginViewModelWithMock.authState {
            #expect(message == "Unauthorized access")
        } else {
            #expect(false, "Expected error state")
        }
    }
    
    @Test("Concurrent service operations")
    func testConcurrentServiceOperations() async {
        let mockNetworkService = MockNetworkService()
        let authService = AuthService(networkService: mockNetworkService)
        let foodService = FoodService(networkService: mockNetworkService)
        
        // Test concurrent operations
        async let loginTask = authService.login(username: "test", password: "password")
        async let foodTask = foodService.fetchFoodItems(token: "test-token")
        
        // Both should complete without deadlocks
        do {
            _ = try await loginTask
            _ = try await foodTask
            #expect(true, "Concurrent operations completed successfully")
        } catch {
            #expect(false, "Concurrent operations failed: \(error)")
        }
    }
}
