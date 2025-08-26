//
//  TestHelpers.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import XCTest
@testable import UnitAndUITestPOC

// MARK: - Test Data Factory

struct TestDataFactory {
    
    // MARK: - Auth Test Data
    
    static func createLoginRequest(username: String = "testuser", password: String = "testpass") -> LoginRequest {
        return LoginRequest(username: username, password: password)
    }
    
    static func createLoginResponse(accessToken: String = "test-access-token", refreshToken: String = "test-refresh-token") -> LoginResponse {
        return LoginResponse(accessToken: accessToken, refreshToken: refreshToken)
    }
    
    // MARK: - Food Test Data
    
    static func createFoodItem(
        id: Int = 1,
        name: String = "Test Pizza",
        description: String = "Delicious test pizza",
        price: Double = 12.99,
        imageUrl: String = "https://example.com/pizza.jpg",
        category: String = "Italian"
    ) -> FoodItem {
        return FoodItem(
            id: id,
            name: name,
            description: description,
            price: price,
            imageUrl: imageUrl,
            category: category
        )
    }
    
    static func createFoodItems(count: Int = 2) -> [FoodItem] {
        return (1...count).map { index in
            createFoodItem(
                id: index,
                name: "Test Food \(index)",
                description: "Delicious test food \(index)",
                price: Double(index) * 5.99,
                imageUrl: "https://example.com/food\(index).jpg",
                category: "Test Category"
            )
        }
    }
    
    static func createFoodItemsResponse(foodItems: [FoodItem]? = nil) -> FoodItemsResponse {
        let items = foodItems ?? createFoodItems()
        return FoodItemsResponse(foodItems: items)
    }
    
    // MARK: - JSON Test Data
    
    static func createLoginResponseJSON(accessToken: String = "test-access-token", refreshToken: String = "test-refresh-token") -> String {
        return """
        {
            "accessToken": "\(accessToken)",
            "refreshToken": "\(refreshToken)"
        }
        """
    }
    
    static func createFoodItemsResponseJSON(foodItems: [FoodItem]? = nil) -> String {
        let items = foodItems ?? createFoodItems()
        let foodItemsJSON = items.map { item in
            """
            {
                "id": \(item.id),
                "name": "\(item.name)",
                "description": "\(item.description)",
                "price": \(item.price),
                "imageUrl": "\(item.imageUrl)",
                "category": "\(item.category)"
            }
            """
        }.joined(separator: ",")
        
        return """
        {
            "foodItems": [\(foodItemsJSON)]
        }
        """
    }
    
    // MARK: - HTTP Response Test Data
    
    static func createHTTPResponse(
        url: String = "http://localhost:3000/test",
        statusCode: Int = 200,
        headerFields: [String: String]? = nil
    ) -> HTTPURLResponse {
        let defaultHeaders = ["Content-Type": "application/json"]
        let headers = headerFields ?? defaultHeaders
        
        return HTTPURLResponse(
            url: URL(string: url)!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: headers
        )!
    }
}

// MARK: - XCTestCase Extensions

extension XCTestCase {
    
    // MARK: - Async Testing Helpers
    
    func XCTAssertThrowsAsyncError<T>(
        _ expression: @escaping () async throws -> T,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line,
        _ errorHandler: (_ error: Error) -> Void = { _ in }
    ) async {
        do {
            _ = try await expression()
            XCTFail("Expected error to be thrown, but no error was thrown. \(message())", file: file, line: line)
        } catch {
            errorHandler(error)
        }
    }
    
    func XCTAssertThrowsAsyncError<T>(
        _ expression: @escaping () async throws -> T,
        _ expectedError: Error,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            _ = try await expression()
            XCTFail("Expected error \(expectedError) to be thrown, but no error was thrown. \(message())", file: file, line: line)
        } catch {
            XCTAssertEqual(error as? NetworkError, expectedError as? NetworkError, message(), file: file, line: line)
        }
    }
    
    // MARK: - State Verification Helpers
    
    func XCTAssertAuthState(
        _ viewModel: LoginViewModel,
        _ expectedState: AuthState,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(viewModel.authState, expectedState, message(), file: file, line: line)
    }
    
    func XCTAssertFoodState(
        _ viewModel: FoodViewModel,
        _ expectedState: FoodLoadingState,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(viewModel.foodState, expectedState, message(), file: file, line: line)
    }
    
    // MARK: - Mock Verification Helpers
    
    func XCTAssertMockNetworkServiceCalled(
        _ mockService: MockNetworkService,
        expectedPath: String,
        expectedMethod: HTTPMethod,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertNotNil(mockService.lastEndpoint, "Network service was not called", file: file, line: line)
        XCTAssertEqual(mockService.lastEndpoint?.path, expectedPath, "Expected path \(expectedPath), got \(mockService.lastEndpoint?.path ?? "nil")", file: file, line: line)
        XCTAssertEqual(mockService.lastEndpoint?.method, expectedMethod, "Expected method \(expectedMethod), got \(mockService.lastEndpoint?.method.rawValue ?? "nil")", file: file, line: line)
    }
}

// MARK: - Mock Service Extensions

extension MockAuthService {
    func configureForSuccess(accessToken: String = "test-access-token", refreshToken: String = "test-refresh-token") {
        mockResponse = TestDataFactory.createLoginResponse(accessToken: accessToken, refreshToken: refreshToken)
        mockError = nil
    }
    
    func configureForFailure(_ error: Error) {
        mockResponse = nil
        mockError = error
    }
}

extension MockFoodService {
    func configureForSuccess(foodItems: [FoodItem]? = nil) {
        mockFoodItems = foodItems ?? TestDataFactory.createFoodItems()
        mockError = nil
    }
    
    func configureForFailure(_ error: Error) {
        mockFoodItems = []
        mockError = error
    }
}

extension MockNetworkService {
    func configureForSuccess<T: Codable & Sendable>(_ response: T) {
        mockResponse = response
        mockError = nil
    }
    
    func configureForFailure(_ error: Error) {
        mockResponse = nil
        mockError = error
    }
}

// MARK: - Test Constants

enum TestConstants {
    static let timeout: TimeInterval = 5.0
    static let performanceIterations = 1000
    static let largeDataSize = 1000
    
    enum URLs {
        static let baseURL = "http://localhost:3000"
        static let loginURL = "\(baseURL)/login"
        static let foodItemsURL = "\(baseURL)/food-items"
    }
    
    enum TestData {
        static let validUsername = "testuser"
        static let validPassword = "testpass"
        static let validToken = "test-token-123"
        static let invalidToken = ""
    }
}

// MARK: - Test Utilities

struct TestUtilities {
    
    static func createMockURLSession(
        data: Data? = nil,
        response: HTTPURLResponse? = nil,
        error: Error? = nil
    ) -> MockURLSession {
        let mockSession = MockURLSession()
        mockSession.mockData = data
        mockSession.mockResponse = response
        mockSession.mockError = error
        return mockSession
    }
    
    static func createMockURLSessionWithJSONResponse(
        jsonString: String,
        statusCode: Int = 200
    ) -> MockURLSession {
        let data = jsonString.data(using: .utf8)!
        let response = TestDataFactory.createHTTPResponse(statusCode: statusCode)
        return createMockURLSession(data: data, response: response)
    }
    
    static func createMockURLSessionWithError(_ error: Error) -> MockURLSession {
        return createMockURLSession(error: error)
    }
    
    static func createMockURLSessionWithServerError(statusCode: Int) -> MockURLSession {
        let response = TestDataFactory.createHTTPResponse(statusCode: statusCode)
        return createMockURLSession(data: Data(), response: response)
    }
}
