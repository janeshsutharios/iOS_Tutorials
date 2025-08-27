//
//  NetworkTests.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import XCTest
@testable import UnitAndUITestPOC

@MainActor
final class NetworkTests: XCTestCase {
    
    // MARK: - APIEndpoint Tests
    
    func testLoginEndpointProperties() async {
        let loginRequest = LoginRequest(username: "testuser", password: "testpass")
        let endpoint = APIEndpoint.login(loginRequest)
        
        XCTAssertEqual(endpoint.baseURL, "http://localhost:3000")
        XCTAssertEqual(endpoint.path, "/login")
        XCTAssertEqual(endpoint.method, .POST)
        XCTAssertNil(endpoint.token)
        
        let url = endpoint.url
        XCTAssertEqual(url?.absoluteString, "http://localhost:3000/login")
        
        let body = endpoint.body
        XCTAssertNotNil(body)
        
        // Verify body contains the login request
        if let body = body {
            let decodedRequest = try? JSONDecoder().decode(LoginRequest.self, from: body)
            XCTAssertEqual(decodedRequest?.username, "testuser")
            XCTAssertEqual(decodedRequest?.password, "testpass")
        }
    }
    
    func testFoodItemsEndpointProperties() async {
        let token = "test-token-123"
        let endpoint = APIEndpoint.foodItems(token)
        
        XCTAssertEqual(endpoint.baseURL, "http://localhost:3000")
        XCTAssertEqual(endpoint.path, "/food-items")
        XCTAssertEqual(endpoint.method, .GET)
        XCTAssertEqual(endpoint.token, token)
        
        let url = endpoint.url
        XCTAssertEqual(url?.absoluteString, "http://localhost:3000/food-items")
        
        let body = endpoint.body
        XCTAssertNil(body)
    }
    
    func testHTTPMethodRawValues() {
        XCTAssertEqual(HTTPMethod.GET.rawValue, "GET")
        XCTAssertEqual(HTTPMethod.POST.rawValue, "POST")
        XCTAssertEqual(HTTPMethod.PUT.rawValue, "PUT")
        XCTAssertEqual(HTTPMethod.DELETE.rawValue, "DELETE")
    }
    
    // MARK: - NetworkError Tests
    
    func testNetworkErrorEquality() {
        XCTAssertEqual(NetworkError.invalidURL, NetworkError.invalidURL)
        XCTAssertEqual(NetworkError.noData, NetworkError.noData)
        XCTAssertEqual(NetworkError.decodingError, NetworkError.decodingError)
        XCTAssertEqual(NetworkError.unauthorized, NetworkError.unauthorized)
        XCTAssertEqual(NetworkError.unknown, NetworkError.unknown)
        XCTAssertEqual(NetworkError.serverError(400), NetworkError.serverError(400))
        XCTAssertEqual(NetworkError.serverError(500), NetworkError.serverError(500))
        
        XCTAssertNotEqual(NetworkError.invalidURL, NetworkError.noData)
        XCTAssertNotEqual(NetworkError.serverError(400), NetworkError.serverError(500))
    }
    
    func testNetworkErrorDescriptions() {
        XCTAssertEqual(NetworkError.invalidURL.errorDescription, "Invalid URL")
        XCTAssertEqual(NetworkError.noData.errorDescription, "No data received")
        XCTAssertEqual(NetworkError.decodingError.errorDescription, "Failed to decode response")
        XCTAssertEqual(NetworkError.unauthorized.errorDescription, "Unauthorized access")
        XCTAssertEqual(NetworkError.unknown.errorDescription, "Unknown error occurred")
        XCTAssertEqual(NetworkError.serverError(400).errorDescription, "Server error with code: 400")
        XCTAssertEqual(NetworkError.serverError(500).errorDescription, "Server error with code: 500")
    }
    
    func testNetworkErrorWithCustomError() {
        let customError = NSError(domain: "TestDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Custom error"])
        let networkError = NetworkError.networkError(customError)
        
        XCTAssertEqual(networkError.errorDescription, "Network error: Custom error")
    }
    
    // MARK: - NetworkService Tests
    
    func testNetworkServiceInitialization() {
        let session = URLSession.shared
        let networkService = NetworkService(session: session)
        
        // Test that the service can be initialized
        XCTAssertNotNil(networkService)
    }
    
    func testNetworkServiceWithMockSession() async throws {
        // Create a mock URLSession that returns predefined data
        let mockData = """
        {
            "accessToken": "test-access-token",
            "refreshToken": "test-refresh-token"
        }
        """.data(using: .utf8)!
        
        let mockResponse = HTTPURLResponse(
            url: URL(string: "http://localhost:3000/login")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        
        let mockSession = MockURLSession()
        mockSession.mockData = mockData
        mockSession.mockResponse = mockResponse
        
        let networkService = NetworkService(session: mockSession)
        let loginRequest = LoginRequest(username: "testuser", password: "testpass")
        let endpoint = APIEndpoint.login(loginRequest)
        
        let response: LoginResponse = try await networkService.request(endpoint)
        
        XCTAssertEqual(response.accessToken, "test-access-token")
        XCTAssertEqual(response.refreshToken, "test-refresh-token")
    }
    
    func testNetworkServiceWithServerError() async {
        let mockResponse = HTTPURLResponse(
            url: URL(string: "http://localhost:3000/login")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let mockSession = MockURLSession()
        mockSession.mockData = Data()
        mockSession.mockResponse = mockResponse
        
        let networkService = NetworkService(session: mockSession)
        let loginRequest = LoginRequest(username: "testuser", password: "testpass")
        let endpoint = APIEndpoint.login(loginRequest)
        
        do {
            let _: LoginResponse = try await networkService.request(endpoint)
            XCTFail("Expected NetworkError.serverError but no error was thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.serverError(500))
        } catch {
            XCTFail("Expected NetworkError but got \(error)")
        }
    }
    
    func testNetworkServiceWithUnauthorizedError() async {
        let mockResponse = HTTPURLResponse(
            url: URL(string: "http://localhost:3000/login")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let mockSession = MockURLSession()
        mockSession.mockData = Data()
        mockSession.mockResponse = mockResponse
        
        let networkService = NetworkService(session: mockSession)
        let loginRequest = LoginRequest(username: "testuser", password: "testpass")
        let endpoint = APIEndpoint.login(loginRequest)
        
        do {
            let _: LoginResponse = try await networkService.request(endpoint)
            XCTFail("Expected NetworkError.unauthorized but no error was thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.unauthorized)
        } catch {
            XCTFail("Expected NetworkError but got \(error)")
        }
    }
    
    func testNetworkServiceWithDecodingError() async {
        let invalidJSON = """
        {
            "invalid": "json"
        }
        """.data(using: .utf8)!
        
        let mockResponse = HTTPURLResponse(
            url: URL(string: "http://localhost:3000/login")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        
        let mockSession = MockURLSession()
        mockSession.mockData = invalidJSON
        mockSession.mockResponse = mockResponse
        
        let networkService = NetworkService(session: mockSession)
        let loginRequest = LoginRequest(username: "testuser", password: "testpass")
        let endpoint = APIEndpoint.login(loginRequest)
        
        do {
            let _: LoginResponse = try await networkService.request(endpoint)
            XCTFail("Expected NetworkError.decodingError but no error was thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.decodingError)
        } catch {
            XCTFail("Expected NetworkError but got \(error)")
        }
    }
}

// MARK: - Mock URLSession

final class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockResponse: HTTPURLResponse?
    var mockError: Error?
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        
        guard let response = mockResponse else {
            throw NetworkError.unknown
        }
        
        return (mockData ?? Data(), response)
    }
}
// Below example is inheritnig concrete URLSession, which is not testable hence use protocol URLSessionProtocol
//final class MockURLSession: URLSession {
//    var mockData: Data?
//    var mockResponse: HTTPURLResponse?
//    var mockError: Error?
//    
//    override func data(for request: URLRequest) async throws -> (Data, URLResponse) {
//        if let error = mockError {
//            throw error
//        }
//        
//        guard let response = mockResponse else {
//            throw NetworkError.unknown
//        }
//        
//        return (mockData ?? Data(), response)
//    }
//}
