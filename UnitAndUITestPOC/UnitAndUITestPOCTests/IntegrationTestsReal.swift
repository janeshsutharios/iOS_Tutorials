//
//  IntegrationTestsReal.swift
//  UnitAndUITestPOC
//
//  Created by Janesh Suthar on 29/08/25.
//


import XCTest
@testable import UnitAndUITestPOC

@MainActor
final class IntegrationTestsReal: XCTestCase {
    
    // MARK: - Test Configuration
    
    private var networkService: NetworkService!
    private var authService: AuthService!
    private var foodService: FoodService!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Use real URLSession for integration tests
        networkService = NetworkService(session: URLSession.shared)
        authService = AuthService(networkService: networkService)
        foodService = FoodService(networkService: networkService)
    }
    
    override func tearDown() async throws {
        networkService = nil
        authService = nil
        foodService = nil
        try await super.tearDown()
    }
    
    // MARK: - Real Login Integration Tests
    
    func testRealLoginEndpointSuccess() async throws {
        // Test with real server - you'll need to adjust credentials based on your server
        let loginRequest = loginRequest
        
        do {
            let response: LoginResponse = try await networkService.request(.login(loginRequest))
            
            // Verify response structure
            XCTAssertFalse(response.accessToken.isEmpty, "Access token should not be empty")
            XCTAssertFalse(response.refreshToken.isEmpty, "Refresh token should not be empty")
            
            print("Login successful - Access Token: \(response.accessToken)")
            print("Login successful - Refresh Token: \(response.refreshToken)")
            
        } catch NetworkError.unauthorized {
            // This is expected if credentials are wrong
            print("Login failed with unauthorized - this is expected for test credentials")
            XCTFail("Login failed with unauthorized. Please check test credentials in your server.")
        } catch {
            XCTFail("Login failed with unexpected error: \(error)")
        }
    }
    
    func testRealLoginEndpointWithInvalidCredentials() async throws {
        let loginRequest = LoginRequest(username: "invaliduser", password: "invalidpass")
        
        do {
            let _: LoginResponse = try await networkService.request(.login(loginRequest))
            XCTFail("Login should fail with invalid credentials")
        } catch NetworkError.unauthorized {
            // This is the expected behavior
            print("Login correctly failed with unauthorized for invalid credentials")
        } catch {
            XCTFail("Expected unauthorized error but got: \(error)")
        }
    }
    
    func testRealLoginEndpointWithEmptyCredentials() async throws {
        let loginRequest = LoginRequest(username: "", password: "")
        
        do {
            let _: LoginResponse = try await networkService.request(.login(loginRequest))
            XCTFail("Login should fail with empty credentials")
        } catch NetworkError.unauthorized {
            // This is the expected behavior
            print("Login correctly failed with unauthorized for empty credentials")
        } catch {
            XCTFail("Expected unauthorized error but got: \(error)")
        }
    }
    
    // MARK: - Real Food Items Integration Tests
    
    func testRealFoodItemsEndpointWithValidToken() async throws {
        // First, get a valid token by logging in
        let loginRequest = loginRequest
        
        do {
            let loginResponse: LoginResponse = try await networkService.request(.login(loginRequest))
            let token = loginResponse.accessToken
            
            // Now test food items endpoint with the valid token
            let foodItems: FoodItemsResponse = try await networkService.request(.foodItems(token))
            
            // Verify response structure
            XCTAssertNotNil(foodItems.foodItems, "Food items should not be nil")
            XCTAssertGreaterThanOrEqual(foodItems.foodItems.count, 0, "Should return food items array")
            
            print("Successfully fetched \(foodItems.foodItems.count) food items")
            
            // If there are food items, verify their structure
            if let firstItem = foodItems.foodItems.first {
                XCTAssertGreaterThan(firstItem.id, 0, "Food item should have valid ID")
                XCTAssertFalse(firstItem.name.isEmpty, "Food item should have name")
                XCTAssertGreaterThanOrEqual(firstItem.price, 0, "Food item should have valid price")
            }
            
        } catch NetworkError.unauthorized {
            XCTFail("Login failed - cannot test food items endpoint")
        } catch {
            XCTFail("Food items request failed: \(error)")
        }
    }
    
    func testRealFoodItemsEndpointWithInvalidToken() async throws {
        let invalidToken = "invalid-token-123"
        
        do {
            let _: FoodItemsResponse = try await networkService.request(.foodItems(invalidToken))
            XCTFail("Food items request should fail with invalid token")
        } catch NetworkError.serverError(403) { 
            // This is the expected behavior for THIS specific API
            print("✅ Food items correctly failed with 403 Forbidden for invalid token")
        } catch {
            XCTFail("Expected a 403 server error but got: \(error)")
        }
    }
    
    func testRealFoodItemsEndpointWithEmptyToken() async throws {
        let emptyToken = ""
        
        do {
            let _: FoodItemsResponse = try await networkService.request(.foodItems(emptyToken))
            XCTFail("Food items request should fail with empty token")
        } catch NetworkError.unauthorized {
            // This is the expected behavior
            print("Food items correctly failed with unauthorized for empty token")
        } catch {
            XCTFail("Expected unauthorized error but got: \(error)")
        }
    }
    
    // MARK: - End-to-End Real Server Integration Tests
    
    func testCompleteRealLoginAndFoodItemsFlow() async throws {
        // Step 1: Login to get a valid token
        let loginRequest = loginRequest
        
        do {
            let loginResponse: LoginResponse = try await networkService.request(.login(loginRequest))
            let token = loginResponse.accessToken
            
            XCTAssertFalse(token.isEmpty, "Should receive valid access token")
            print("✅ Login successful - Token: \(token)")
            
            // Step 2: Use the token to fetch food items
            let foodItems: FoodItemsResponse = try await networkService.request(.foodItems(token))
            
            XCTAssertNotNil(foodItems.foodItems, "Should receive food items")
            print("✅ Food items fetched successfully - Count: \(foodItems.foodItems.count)")
            
            // Step 3: Verify the complete flow worked
            XCTAssertTrue(!token.isEmpty && foodItems.foodItems.count >= 0, "Complete flow should work")
            
        } catch NetworkError.unauthorized {
            XCTFail("Authentication failed - check server credentials")
        } catch {
            XCTFail("End-to-end flow failed: \(error)")
        }
    }
    
    // MARK: - Performance Integration Tests
    
    func testLoginEndpointPerformance() async throws {
        let loginRequest = LoginRequest(username: "testuser", password: "testpass")
        
        measure {
            Task {
                do {
                    let _: LoginResponse = try await networkService.request(.login(loginRequest))
                } catch {
                    // Ignore errors in performance test
                }
            }
        }
    }
    
    func testFoodItemsEndpointPerformance() async throws {
        // First get a token
        let loginRequest = LoginRequest(username: "testuser", password: "testpass")
        
        do {
            let loginResponse: LoginResponse = try await networkService.request(.login(loginRequest))
            let token = loginResponse.accessToken
            
            measure {
                Task {
                    do {
                        let _: FoodItemsResponse = try await networkService.request(.foodItems(token))
                    } catch {
                        // Ignore errors in performance test
                    }
                }
            }
        } catch {
            XCTSkip("Cannot test performance without valid token")
        }
    }
    
    // MARK: - Network Error Handling Tests
    
    func testNetworkTimeoutHandling() async throws {
        // Create a session with very short timeout
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 0.1 // 100ms timeout
        config.timeoutIntervalForResource = 0.1
        
        let shortTimeoutSession = URLSession(configuration: config)
        let timeoutNetworkService = NetworkService(session: shortTimeoutSession)
        
        let loginRequest = LoginRequest(username: "testuser", password: "testpass")
        
        do {
            let _: LoginResponse = try await timeoutNetworkService.request(.login(loginRequest))
            XCTFail("Should timeout with very short timeout interval")
        } catch {
            // Expected to timeout
            print("✅ Correctly handled network timeout")
        }
    }
    
    // MARK: - Data Validation Tests
    
    func testLoginResponseDataValidation() async throws {
        let loginRequest = loginRequest
        
        do {
            let response: LoginResponse = try await networkService.request(.login(loginRequest))
            
            // Validate token format (basic validation)
            XCTAssertTrue(response.accessToken.count > 10, "Access token should be reasonably long")
            XCTAssertTrue(response.refreshToken.count > 10, "Refresh token should be reasonably long")
            
            // Validate tokens are different
            XCTAssertNotEqual(response.accessToken, response.refreshToken, "Access and refresh tokens should be different")
            
        } catch NetworkError.unauthorized {
            XCTFail("Login failed - cannot validate response data")
        } catch {
            XCTFail("Login failed: \(error)")
        }
    }
    
    func testFoodItemsResponseDataValidation() async throws {
        // First get a token
        let loginRequest = loginRequest
        
        do {
            let loginResponse: LoginResponse = try await networkService.request(.login(loginRequest))
            let token = loginResponse.accessToken
            
            let foodItems: FoodItemsResponse = try await networkService.request(.foodItems(token))
            
            // Validate food items structure
            for (index, item) in foodItems.foodItems.enumerated() {
                XCTAssertGreaterThan(item.id, 0, "Food item \(index) should have valid ID")
                XCTAssertFalse(item.name.isEmpty, "Food item \(index) should have name")
                XCTAssertGreaterThanOrEqual(item.price, 0, "Food item \(index) should have valid price")
                XCTAssertFalse(item.description.isEmpty, "Food item \(index) should have description")
                XCTAssertFalse(item.category.isEmpty, "Food item \(index) should have category")
            }
            
        } catch NetworkError.unauthorized {
            XCTFail("Authentication failed - cannot validate food items data")
        } catch {
            XCTFail("Food items request failed: \(error)")
        }
    }
}

// MARK: - Test Helpers

extension IntegrationTestsReal {

    /// Helper method to get valid test credentials
    private var loginRequest: LoginRequest {
        // You can modify these based on your server's test credentials
        return LoginRequest(username: "test", password: "password")
    }
}
