//
//  FoodViewModelTests.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import XCTest
@testable import UnitAndUITestPOC

@MainActor
final class FoodViewModelTests: XCTestCase {
    var mockFoodService: MockFoodService!
    var viewModel: FoodViewModel!
    
    override func setUp() {
        super.setUp()
        mockFoodService = MockFoodService()
        viewModel = FoodViewModel(foodService: mockFoodService)
    }
    
    override func tearDown() {
        mockFoodService.reset()
        mockFoodService = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testInitialState() {
        // Given & When & Then
        XCTAssertEqual(viewModel.foodState, .idle)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.foodItems.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchFoodItemsSuccess() async {
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
        mockFoodService.mockFoodItems = expectedFoodItems
        
        // When
        await viewModel.fetchFoodItems(token: "test-token")
        
        // Then
        if case .loaded(let items) = viewModel.foodState {
            XCTAssertEqual(items.count, 2)
            XCTAssertEqual(items[0].name, "Test Burger")
            XCTAssertEqual(items[1].name, "Test Pizza")
        } else {
            XCTFail("Expected loaded state")
        }
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.foodItems.count, 2)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(mockFoodService.fetchCallCount, 1)
        XCTAssertEqual(mockFoodService.lastToken, "test-token")
    }
    
    func testFetchFoodItemsFailure() async {
        // Given
        mockFoodService.shouldSucceed = false
        mockFoodService.mockError = NetworkError.unauthorized
        
        // When
        await viewModel.fetchFoodItems(token: "test-token")
        
        // Then
        if case .error(let message) = viewModel.foodState {
            XCTAssertEqual(message, "Unauthorized access")
        } else {
            XCTFail("Expected error state")
        }
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.foodItems.isEmpty)
        XCTAssertEqual(viewModel.errorMessage, "Unauthorized access")
    }
    
    func testFetchFoodItemsWithEmptyToken() async {
        // Given
        let emptyToken = ""
        
        // When
        await viewModel.fetchFoodItems(token: emptyToken)
        
        // Then
        if case .error(let message) = viewModel.foodState {
            XCTAssertEqual(message, "Invalid token")
        } else {
            XCTFail("Expected error state")
        }
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.foodItems.isEmpty)
        XCTAssertEqual(viewModel.errorMessage, "Invalid token")
        XCTAssertEqual(mockFoodService.fetchCallCount, 0)
    }
    
    func testFetchFoodItemsEmptyResponse() async {
        // Given
        mockFoodService.mockFoodItems = []
        
        // When
        await viewModel.fetchFoodItems(token: "test-token")
        
        // Then
        if case .loaded(let items) = viewModel.foodState {
            XCTAssertTrue(items.isEmpty)
        } else {
            XCTFail("Expected loaded state")
        }
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.foodItems.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchFoodItemsLoadingState() async {
        // Given
        let expectation = XCTestExpectation(description: "Fetch completion")
        
        // When
        Task {
            await viewModel.fetchFoodItems(token: "test-token")
            expectation.fulfill()
        }
        
        // Check loading state immediately after starting
        XCTAssertEqual(viewModel.foodState, .loading)
        XCTAssertTrue(viewModel.isLoading)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    func testResetState() {
        // Given
        viewModel.foodState = .error("test error")
        
        // When
        viewModel.resetState()
        
        // Then
        XCTAssertEqual(viewModel.foodState, .idle)
    }
    
    func testIsLoadingComputedProperty() {
        // Given & When & Then
        viewModel.foodState = .idle
        XCTAssertFalse(viewModel.isLoading)
        
        viewModel.foodState = .loading
        XCTAssertTrue(viewModel.isLoading)
        
        viewModel.foodState = .loaded([])
        XCTAssertFalse(viewModel.isLoading)
        
        viewModel.foodState = .error("test")
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testFoodItemsComputedProperty() {
        // Given
        let testItems = [
            FoodItem(
                id: 1,
                name: "Test Item",
                description: "Test",
                price: 9.99,
                imageUrl: "https://example.com/image.jpg",
                category: "Test"
            )
        ]
        
        // When & Then
        viewModel.foodState = .idle
        XCTAssertTrue(viewModel.foodItems.isEmpty)
        
        viewModel.foodState = .loading
        XCTAssertTrue(viewModel.foodItems.isEmpty)
        
        viewModel.foodState = .loaded(testItems)
        XCTAssertEqual(viewModel.foodItems.count, 1)
        XCTAssertEqual(viewModel.foodItems.first?.name, "Test Item")
        
        viewModel.foodState = .error("test")
        XCTAssertTrue(viewModel.foodItems.isEmpty)
    }
    
    func testErrorMessageComputedProperty() {
        // Given & When & Then
        viewModel.foodState = .idle
        XCTAssertNil(viewModel.errorMessage)
        
        viewModel.foodState = .loading
        XCTAssertNil(viewModel.errorMessage)
        
        viewModel.foodState = .loaded([])
        XCTAssertNil(viewModel.errorMessage)
        
        viewModel.foodState = .error("test error")
        XCTAssertEqual(viewModel.errorMessage, "test error")
    }
}
