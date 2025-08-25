//
//  APIEndpointSwiftTests.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import Testing
@testable import UnitAndUITestPOC

@Suite("API Endpoint Configuration")
struct APIEndpointSwiftTests {
    
    @Test("Login endpoint configuration")
    func testLoginEndpointConfiguration() {
        let loginRequest = LoginRequest(username: "test", password: "password")
        let endpoint = APIEndpoint.login(loginRequest)
        
        #expect(endpoint.baseURL == "http://localhost:3000")
        #expect(endpoint.path == "/login")
        #expect(endpoint.method == .POST)
        #expect(endpoint.url?.absoluteString == "http://localhost:3000/login")
        #expect(endpoint.token == nil)
        
        // Test body encoding
        let body = endpoint.body as? LoginRequest
        #expect(body != nil)
        #expect(body?.username == "test")
        #expect(body?.password == "password")
    }
    
    @Test("FoodItems endpoint configuration")
    func testFoodItemsEndpointConfiguration() {
        let token = "test-token"
        let endpoint = APIEndpoint.foodItems(token)
        
        #expect(endpoint.baseURL == "http://localhost:3000")
        #expect(endpoint.path == "/food-items")
        #expect(endpoint.method == .GET)
        #expect(endpoint.url?.absoluteString == "http://localhost:3000/food-items")
        #expect(endpoint.token == "test-token")
        #expect(endpoint.body == nil)
    }
    
    @Test("HTTPMethod raw values")
    func testHTTPMethodRawValues() {
        #expect(HTTPMethod.GET.rawValue == "GET")
        #expect(HTTPMethod.POST.rawValue == "POST")
        #expect(HTTPMethod.PUT.rawValue == "PUT")
        #expect(HTTPMethod.DELETE.rawValue == "DELETE")
    }
}
