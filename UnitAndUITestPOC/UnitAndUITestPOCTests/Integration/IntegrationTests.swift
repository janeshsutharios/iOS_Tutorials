//
//  IntegrationTests.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import XCTest
@testable import UnitAndUITestPOC

final class IntegrationTests: XCTestCase {
    var networkService: NetworkService!
    var authService: AuthService!
    var foodService: FoodService!
    var loginViewModel: LoginViewModel!
    var foodViewModel: FoodViewModel!
    
    override func setUp() {
        super.setUp()
        networkService = NetworkService()
        authService = AuthService(networkService: networkService)
        foodService = FoodService(networkService: networkService)
        loginViewModel = LoginViewModel(authService: authService)
        foodViewModel = FoodViewModel(foodService: foodService)
    }
    
    override func tearDown() {
        networkService = nil
        authService = nil
        foodService = nil
        loginViewModel = nil
        foodViewModel = nil
        super.tearDown()
    }
    
    func testLoginToFoodFlow() async {
        // Given
        loginViewModel.username = "test"
        loginViewModel.password = "password"
        
        // When - Login
        await loginViewModel.login()
        
        // Then - Verify login success
        XCTAssertTrue(loginViewModel.isAuthenticated)
        XCTAssertFalse(loginViewModel.accessToken.isEmpty)
        
        // When - Fetch food items with the token
        await foodViewModel.fetchFoodItems(token: loginViewModel.accessToken)
        
        // Then - Verify food items are loaded
        if case .loaded(let items) = foodViewModel.foodState {
            XCTAssertFalse(items.isEmpty)
            XCTAssertTrue(items.count > 0)
        } else {
            XCTFail("Expected food items to be loaded")
        }
    }
    
    func testServiceDependencyInjection() {
        // Given & When & Then
        // Test that services can be injected with different network services
        let mockNetworkService = MockNetworkService()
        let authServiceWithMock = AuthService(networkService: mockNetworkService)
        let foodServiceWithMock = FoodService(networkService: mockNetworkService)
        
        XCTAssertNotNil(authServiceWithMock)
        XCTAssertNotNil(foodServiceWithMock)
    }
    
    func testViewModelDependencyInjection() {
        // Given & When & Then
        // Test that view models can be injected with different services
        let mockAuthService = MockAuthService()
        let mockFoodService = MockFoodService()
        
        let loginViewModelWithMock = LoginViewModel(authService: mockAuthService)
        let foodViewModelWithMock = FoodViewModel(foodService: mockFoodService)
        
        XCTAssertNotNil(loginViewModelWithMock)
        XCTAssertNotNil(foodViewModelWithMock)
    }
    
    func testErrorPropagation() async {
        // Given
        let mockNetworkService = MockNetworkService()
        mockNetworkService.shouldSucceed = false
        mockNetworkService.mockError = NetworkError.unauthorized
        
        let authServiceWithMock = AuthService(networkService: mockNetworkService)
        let loginViewModelWithMock = LoginViewModel(authService: authServiceWithMock)
        
        loginViewModelWithMock.username = "test"
        loginViewModelWithMock.password = "password"
        
        // When
        await loginViewModelWithMock.login()
        
        // Then
        if case .error(let message) = loginViewModelWithMock.authState {
            XCTAssertEqual(message, "Unauthorized access")
        } else {
            XCTFail("Expected error state")
        }
    }
}
