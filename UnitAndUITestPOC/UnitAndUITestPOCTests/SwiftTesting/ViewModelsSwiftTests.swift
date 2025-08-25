//
//  ViewModelsSwiftTests.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import Testing
@testable import UnitAndUITestPOC

@Suite("ViewModels")
struct ViewModelsSwiftTests {
    
    @Test("LoginViewModel initial state")
    func testLoginViewModelInitialState() {
        let viewModel = LoginViewModel()
        
        #expect(viewModel.username == "")
        #expect(viewModel.password == "")
        #expect(viewModel.authState == .idle)
        #expect(viewModel.isAuthenticated == false)
        #expect(viewModel.accessToken == "")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test("LoginViewModel login success")
    func testLoginViewModelLoginSuccess() async {
        let mockAuthService = MockAuthService()
        let expectedResponse = LoginResponse(
            accessToken: "test-access-token",
            refreshToken: "test-refresh-token"
        )
        await mockAuthService.setMockResponse(expectedResponse)
        
        let viewModel = LoginViewModel(authService: mockAuthService)
        viewModel.username = "testuser"
        viewModel.password = "testpass"
        
        await viewModel.login()
        
        #expect(viewModel.authState == .authenticated)
        #expect(viewModel.isAuthenticated == true)
        #expect(viewModel.accessToken == "test-access-token")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        let callCount = await mockAuthService.getLoginCallCount()
        #expect(callCount == 1)
        let username = await mockAuthService.getLastUsername()
        #expect(username == "testuser")
        let password = await mockAuthService.getLastPassword()
        #expect(password == "testpass")
    }
    
    @Test("LoginViewModel login failure")
    func testLoginViewModelLoginFailure() async {
        let mockAuthService = MockAuthService()
        await mockAuthService.setShouldSucceed(false)
        await mockAuthService.setMockError(NetworkError.unauthorized)
        
        let viewModel = LoginViewModel(authService: mockAuthService)
        viewModel.username = "testuser"
        viewModel.password = "testpass"
        
        await viewModel.login()
        
        if case .error(let message) = viewModel.authState {
            #expect(message == "Unauthorized access")
        } else {
            #expect(false, "Expected error state")
        }
        #expect(viewModel.isAuthenticated == false)
        #expect(viewModel.accessToken == "")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == "Unauthorized access")
    }
    
    @Test("LoginViewModel login with empty credentials")
    func testLoginViewModelLoginWithEmptyCredentials() async {
        let mockAuthService = MockAuthService()
        let viewModel = LoginViewModel(authService: mockAuthService)
        viewModel.username = ""
        viewModel.password = ""
        
        await viewModel.login()
        
        if case .error(let message) = viewModel.authState {
            #expect(message == "Please enter both username and password")
        } else {
            #expect(false, "Expected error state")
        }
        #expect(viewModel.isAuthenticated == false)
        let callCount = await mockAuthService.getLoginCallCount()
        #expect(callCount == 0)
    }
    
    @Test("LoginViewModel reset state")
    func testLoginViewModelResetState() {
        let viewModel = LoginViewModel()
        viewModel.username = "testuser"
        viewModel.password = "testpass"
        viewModel.authState = .error("test error")
        
        viewModel.resetState()
        
        #expect(viewModel.username == "")
        #expect(viewModel.password == "")
        #expect(viewModel.authState == .idle)
    }
    
    @Test("FoodViewModel initial state")
    func testFoodViewModelInitialState() {
        let viewModel = FoodViewModel()
        
        #expect(viewModel.foodState == .idle)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.foodItems.isEmpty)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test("FoodViewModel fetchFoodItems success")
    func testFoodViewModelFetchFoodItemsSuccess() async {
        let mockFoodService = MockFoodService()
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
        await mockFoodService.setMockFoodItems(expectedFoodItems)
        
        let viewModel = FoodViewModel(foodService: mockFoodService)
        
        await viewModel.fetchFoodItems(token: "test-token")
        
        if case .loaded(let items) = viewModel.foodState {
            #expect(items.count == 2)
            #expect(items[0].name == "Test Burger")
            #expect(items[1].name == "Test Pizza")
        } else {
            #expect(false, "Expected loaded state")
        }
        #expect(viewModel.isLoading == false)
        #expect(viewModel.foodItems.count == 2)
        #expect(viewModel.errorMessage == nil)
        let callCount = await mockFoodService.getFetchCallCount()
        #expect(callCount == 1)
        let token = await mockFoodService.getLastToken()
        #expect(token == "test-token")
    }
    
    @Test("FoodViewModel fetchFoodItems failure")
    func testFoodViewModelFetchFoodItemsFailure() async {
        let mockFoodService = MockFoodService()
        await mockFoodService.setShouldSucceed(false)
        await mockFoodService.setMockError(NetworkError.unauthorized)
        
        let viewModel = FoodViewModel(foodService: mockFoodService)
        
        await viewModel.fetchFoodItems(token: "test-token")
        
        if case .error(let message) = viewModel.foodState {
            #expect(message == "Unauthorized access")
        } else {
            #expect(false, "Expected error state")
        }
        #expect(viewModel.isLoading == false)
        #expect(viewModel.foodItems.isEmpty)
        #expect(viewModel.errorMessage == "Unauthorized access")
    }
    
    @Test("FoodViewModel fetchFoodItems with empty token")
    func testFoodViewModelFetchFoodItemsWithEmptyToken() async {
        let mockFoodService = MockFoodService()
        let viewModel = FoodViewModel(foodService: mockFoodService)
        
        await viewModel.fetchFoodItems(token: "")
        
        if case .error(let message) = viewModel.foodState {
            #expect(message == "Invalid token")
        } else {
            #expect(false, "Expected error state")
        }
        #expect(viewModel.isLoading == false)
        #expect(viewModel.foodItems.isEmpty)
        #expect(viewModel.errorMessage == "Invalid token")
        let callCount = await mockFoodService.getFetchCallCount()
        #expect(callCount == 0)
    }
    
    @Test("FoodViewModel reset state")
    func testFoodViewModelResetState() {
        let viewModel = FoodViewModel()
        viewModel.foodState = .error("test error")
        
        viewModel.resetState()
        
        #expect(viewModel.foodState == .idle)
    }
}
