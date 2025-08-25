//
//  APIEndpointTests.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import XCTest
@testable import UnitAndUITestPOC

final class APIEndpointTests: XCTestCase {
    
    func testLoginEndpointConfiguration() {
        // Given
        let loginRequest = LoginRequest(username: "test", password: "password")
        let endpoint = APIEndpoint.login(loginRequest)
        
        // When & Then
        XCTAssertEqual(endpoint.baseURL, "http://localhost:3000")
        XCTAssertEqual(endpoint.path, "/login")
        XCTAssertEqual(endpoint.method, .POST)
        XCTAssertEqual(endpoint.url?.absoluteString, "http://localhost:3000/login")
        XCTAssertNil(endpoint.token)
        
        // Test body encoding
        let body = endpoint.body as? LoginRequest
        XCTAssertNotNil(body)
        XCTAssertEqual(body?.username, "test")
        XCTAssertEqual(body?.password, "password")
    }
    
    func testFoodItemsEndpointConfiguration() {
        // Given
        let token = "test-token"
        let endpoint = APIEndpoint.foodItems(token)
        
        // When & Then
        XCTAssertEqual(endpoint.baseURL, "http://localhost:3000")
        XCTAssertEqual(endpoint.path, "/food-items")
        XCTAssertEqual(endpoint.method, .GET)
        XCTAssertEqual(endpoint.url?.absoluteString, "http://localhost:3000/food-items")
        XCTAssertEqual(endpoint.token, "test-token")
        XCTAssertNil(endpoint.body)
    }
    
    func testHTTPMethodRawValues() {
        // Given & When & Then
        XCTAssertEqual(HTTPMethod.GET.rawValue, "GET")
        XCTAssertEqual(HTTPMethod.POST.rawValue, "POST")
        XCTAssertEqual(HTTPMethod.PUT.rawValue, "PUT")
        XCTAssertEqual(HTTPMethod.DELETE.rawValue, "DELETE")
    }
}
