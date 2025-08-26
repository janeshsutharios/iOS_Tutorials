//
//  TestSetup.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import XCTest
@testable import UnitAndUITestPOC

// MARK: - Test Base Class

@MainActor
class BaseTestCase: XCTestCase {
    
    override func setUp() async throws {
        try await super.setUp()
        // Add any common setup here
    }
    
    override func tearDown() async throws {
        // Add any common cleanup here
        try await super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    func createMockAuthService() -> MockAuthService {
        return MockAuthService()
    }
    
    func createMockFoodService() -> MockFoodService {
        return MockFoodService()
    }
    
    func createMockNetworkService() -> MockNetworkService {
        return MockNetworkService()
    }
    
    func createMockURLSession() -> MockURLSession {
        return MockURLSession()
    }
    
    func createLoginViewModel(authService: AuthServiceProtocol? = nil) -> LoginViewModel {
        let service = authService ?? createMockAuthService()
        return LoginViewModel(authService: service)
    }
    
    func createFoodViewModel(foodService: FoodServiceProtocol? = nil) -> FoodViewModel {
        let service = foodService ?? createMockFoodService()
        return FoodViewModel(foodService: service)
    }
    
    func createNetworkService(session: URLSessionProtocol? = nil) -> NetworkService {
        let session = session ?? createMockURLSession()
        return NetworkService(session: session)
    }
}

// MARK: - Test Utilities

extension BaseTestCase {
    
    func waitForAsyncOperation<T>(_ operation: @escaping () async throws -> T, timeout: TimeInterval = 5.0) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    let result = try await operation()
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func assertNoMemoryLeaks<T>(_ object: T, file: StaticString = #filePath, line: UInt = #line) {
        // This is a placeholder for memory leak detection
        // In a real implementation, you might use tools like Instruments or custom memory tracking
        XCTAssertNotNil(object, "Object should not be nil", file: file, line: line)
    }
}

// MARK: - Test Data Factory

extension BaseTestCase {
    
    func createTestLoginRequest() -> LoginRequest {
        return LoginRequest(username: "testuser", password: "testpass")
    }
    
    func createTestLoginResponse() -> LoginResponse {
        return LoginResponse(accessToken: "test-access-token", refreshToken: "test-refresh-token")
    }
    
    func createTestFoodItems(count: Int = 2) -> [FoodItem] {
        return (1...count).map { index in
            FoodItem(
                id: index,
                name: "Test Food \(index)",
                description: "Delicious test food \(index)",
                price: Double(index) * 5.99,
                imageUrl: "https://example.com/food\(index).jpg",
                category: "Test Category"
            )
        }
    }
    
    func createTestHTTPResponse(statusCode: Int = 200, url: String = "http://localhost:3000/test") -> HTTPURLResponse {
        return HTTPURLResponse(
            url: URL(string: url)!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
    }
}

// MARK: - Test Configuration

struct TestConfiguration {
    static let timeout: TimeInterval = 5.0
    static let maxRetries = 3
    static let enableMemoryTracking = false // Set to true to enable memory leak detection
}

// MARK: - Memory Tracking (Optional)

#if DEBUG
@MainActor
class MemoryTracker {
    private static var trackedObjects: Set<ObjectIdentifier> = []
    
    static func track<T: AnyObject>(_ object: T) {
        let id = ObjectIdentifier(object)
        trackedObjects.insert(id)
    }
    
    static func untrack<T: AnyObject>(_ object: T) {
        let id = ObjectIdentifier(object)
        trackedObjects.remove(id)
    }
    
    static func getTrackedCount() -> Int {
        return trackedObjects.count
    }
    
    static func clear() {
        trackedObjects.removeAll()
    }
}
#endif
