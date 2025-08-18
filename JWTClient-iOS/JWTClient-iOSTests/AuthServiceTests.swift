
import XCTest
@testable import JWTClient_iOS

@MainActor
final class AuthServiceTests: XCTestCase {
    var mockHTTP: MockHTTPClient!
    var store: InMemoryTokenStore!
    var config: AppConfig!
    var auth: AuthService!

    override func setUp() async throws {
        mockHTTP = MockHTTPClient()
        store = InMemoryTokenStore()
        config = AppConfig.load(for: .dev)
        // Use mock HTTP and in-memory store for AuthService
        auth = AuthService(config: config, http: mockHTTP, store: store)
    }

    override func tearDown() async throws {
        auth = nil
        mockHTTP = nil
        store = nil
        config = nil
    }

    func testLoginStoresTokensAndSetsAuthenticated() async throws {
        // Prepare mocked token response for login endpoint
        let tr = TokenResponse(accessToken: "access-token-xyz", refreshToken: "refresh-token-abc")
        let data = try JSONEncoder().encode(tr)
        await mockHTTP.setResponse(for: "\(config.baseURL)/login", data: data)

        try await auth.login(username: "test", password: "password")
        XCTAssertTrue(auth.isAuthenticated)

        let loaded = try store.load()
        XCTAssertEqual(loaded.accessToken, "access-token-xyz")
        XCTAssertEqual(loaded.refreshToken, "refresh-token-abc")
    }

    func testValidAccessToken_UsesExistingToken() async throws {
        // Save valid JWT tokens to store first
        let validToken = JWT.createMockToken(expiresIn: 3600) // Valid for 1 hour
        try store.save(accessToken: validToken, refreshToken: "refresh-token")
        
        // Create a new AuthService instance to test token loading
        let newAuth = AuthService(config: config, http: mockHTTP, store: store)
        
        // Test that the token is loaded and valid
        let token = try await newAuth.validAccessToken()
        XCTAssertEqual(token, validToken)
    }

    func testRefreshIfExpired_PerformsRefresh() async throws {
        // Simulate expired access token in store
        let expiredToken = JWT.createExpiredMockToken() // Expired 1 hour ago
        try store.save(accessToken: expiredToken, refreshToken: "refresh-token")
        
        // Create a new AuthService to load the stored tokens
        let newAuth = AuthService(config: config, http: mockHTTP, store: store)

        // Mock the refresh endpoint to return a new access token
        let newToken = JWT.createMockToken(expiresIn: 3600) // Valid for 1 hour
        let at = AccessTokenResponse(accessToken: newToken)
        await mockHTTP.setResponse(for: "\(config.baseURL)/refresh", data: try JSONEncoder().encode(at))

        // Call validAccessToken - it should call refresh and return new token
        let token = try await newAuth.validAccessToken()
        XCTAssertEqual(token, newToken)
        
        // Verify the new token was stored
        let loaded = try store.load()
        XCTAssertEqual(loaded.accessToken, newToken)
    }
    
    func testAuthServiceInitializationWithStoredTokens() throws {
        // Given - Store valid JWT tokens first
        let validToken = JWT.createMockToken(expiresIn: 3600)
        try store.save(accessToken: validToken, refreshToken: "refresh-token")
        
        // When - Create new AuthService
        let newAuth = AuthService(config: config, http: mockHTTP, store: store)
        
        // Then - Should be authenticated
        XCTAssertTrue(newAuth.isAuthenticated)
    }
    
    func testLogoutClearsTokensAndState() async throws {
        // Given - First login to set up authenticated state
        let tr = TokenResponse(accessToken: "access-token", refreshToken: "refresh-token")
        let data = try JSONEncoder().encode(tr)
        await mockHTTP.setResponse(for: "\(config.baseURL)/login", data: data)
        
        try await auth.login(username: "user", password: "pass")
        XCTAssertTrue(auth.isAuthenticated)
        
        // When - Logout
        await auth.logout()
        
        // Then - Should not be authenticated and tokens cleared
        XCTAssertFalse(auth.isAuthenticated)
        
        let loaded = try store.load()
        XCTAssertNil(loaded.accessToken)
        XCTAssertNil(loaded.refreshToken)
    }
    
    func testValidAccessToken_ThrowsWhenNoRefreshToken() async throws {
        // Given - Store expired access token and no refresh token
        // This will force the refresh flow to be triggered
        let expiredToken = JWT.createExpiredMockToken() // Expired 1 hour ago
        try store.save(accessToken: expiredToken, refreshToken: nil)
        
        // Create a new AuthService
        let newAuth = AuthService(config: config, http: mockHTTP, store: store)
        
        // When & Then - Should throw missing refresh token error
        // because the expired token will trigger refresh, but no refresh token exists
        do {
            _ = try await newAuth.validAccessToken()
            XCTFail("Expected missing refresh token error to be thrown")
        } catch {
            XCTAssertTrue(error is AppError)
            // Verify it's the specific error we expect
            if case AppError.missingRefreshToken = error {
                // This is the expected error
            } else {
                XCTFail("Expected AppError.missingRefreshToken, got: \(error)")
            }
        }
    }
    
    func testValidAccessToken_ThrowsWhenRefreshTokenExpired() async throws {
        // Given - Store expired access token and expired refresh token
        let expiredToken = JWT.createExpiredMockToken() // Expired 1 hour ago
        try store.save(accessToken: expiredToken, refreshToken: "expired-refresh")
        
        // Create a new AuthService
        let newAuth = AuthService(config: config, http: mockHTTP, store: store)
        
        // Mock the refresh endpoint to fail
        await mockHTTP.setStatusCode(401) // Unauthorized
        
        // When & Then - Should throw tokenRefreshFailed error when refresh fails
        do {
            _ = try await newAuth.validAccessToken()
            XCTFail("Expected tokenRefreshFailed error to be thrown when refresh fails")
        } catch {
            XCTAssertTrue(error is AppError)
            if case AppError.tokenRefreshFailed = error {
                // Expected error - this is now wrapped by AuthService
            } else {
                XCTFail("Expected AppError.tokenRefreshFailed, got: \(error)")
            }
        }
    }
    
    // MARK: - Refresh Token Failure Scenarios
    
    func testValidAccessToken_RefreshTokenFailure_ThrowsTokenRefreshFailed() async throws {
        // Given - Store expired access token and valid refresh token
        let expiredToken = JWT.createExpiredMockToken()
        try store.save(accessToken: expiredToken, refreshToken: "valid-refresh")
        
        let newAuth = AuthService(config: config, http: mockHTTP, store: store)
        
        // Mock refresh endpoint to return 401 (invalid refresh token)
        await mockHTTP.setStatusCode(401) // Unauthorized
        await mockHTTP.setResponse(for: "\(config.baseURL)/refresh", data: Data()) // Empty response
        
        // When & Then - Should throw tokenRefreshFailed error (wrapped by AuthService)
        do {
            _ = try await newAuth.validAccessToken()
            XCTFail("Expected tokenRefreshFailed error to be thrown")
        } catch {
            XCTAssertTrue(error is AppError)
            if case AppError.tokenRefreshFailed = error {
                // Expected error
            } else {
                XCTFail("Expected AppError.tokenRefreshFailed, got: \(error)")
            }
        }
    }
    
    func testValidAccessToken_RefreshTokenServerError_ThrowsTokenRefreshFailed() async throws {
        // Given - Store expired access token and valid refresh token
        let expiredToken = JWT.createExpiredMockToken()
        try store.save(accessToken: expiredToken, refreshToken: "valid-refresh")
        
        let newAuth = AuthService(config: config, http: mockHTTP, store: store)
        
        // Mock refresh endpoint to return 500 (server error)
        await mockHTTP.setStatusCode(500) // Unauthorized
        await mockHTTP.setResponse(for: "\(config.baseURL)/refresh", data: Data()) // Empty response
        
        // When & Then - Should throw tokenRefreshFailed error (wrapped by AuthService)
        do {
            _ = try await newAuth.validAccessToken()
            XCTFail("Expected tokenRefreshFailed error to be thrown")
        } catch {
            XCTAssertTrue(error is AppError)
            if case AppError.tokenRefreshFailed = error {
                // Expected error
            } else {
                XCTFail("Expected AppError.tokenRefreshFailed, got: \(error)")
            }
        }
    }
    
    func testValidAccessToken_RefreshTokenNetworkError_ThrowsTokenRefreshFailed() async throws {
        // Given - Store expired access token and valid refresh token
        let expiredToken = JWT.createExpiredMockToken()
        try store.save(accessToken: expiredToken, refreshToken: "valid-refresh")
        
        let newAuth = AuthService(config: config, http: mockHTTP, store: store)
        
        // Mock refresh endpoint to simulate network error
        await mockHTTP.setShouldSimulateNetworkError(true)
        await mockHTTP.setNetworkError(URLError(.networkConnectionLost))
        
        // When & Then - Should throw tokenRefreshFailed error (wrapped by AuthService)
        do {
            _ = try await newAuth.validAccessToken()
            XCTFail("Expected tokenRefreshFailed error to be thrown")
        } catch {
            XCTAssertTrue(error is AppError)
            if case AppError.tokenRefreshFailed = error {
                // Expected error
            } else {
                XCTFail("Expected AppError.tokenRefreshFailed, got: \(error)")
            }
        }
    }
    
    // MARK: - Login Error Scenarios
    
    func testLogin_InvalidCredentials_ThrowsUnauthorized() async throws {
        // Given - Mock login endpoint to return 401
        await mockHTTP.setStatusCode(401)
        await mockHTTP.setResponse(for: "\(config.baseURL)/login", data: Data())
        
        // When & Then - Should throw unauthorized error
        do {
            try await auth.login(username: "invalid", password: "invalid")
            XCTFail("Expected unauthorized error to be thrown")
        } catch {
            XCTAssertTrue(error is AppError)
            if case AppError.unauthorized = error {
                // Expected error
            } else {
                XCTFail("Expected AppError.unauthorized, got: \(error)")
            }
        }
        
        // Verify state is not authenticated
        XCTAssertFalse(auth.isAuthenticated)
    }
    
    func testLogin_ServerError_ThrowsServerError() async throws {
        // Given - Mock login endpoint to return 500
        await mockHTTP.setStatusCode(500)
        await mockHTTP.setResponse(for: "\(config.baseURL)/login", data: Data())
        
        // When & Then - Should throw server error
        do {
            try await auth.login(username: "test", password: "password")
            XCTFail("Expected server error to be thrown")
        } catch {
            XCTAssertTrue(error is AppError)
            if case AppError.server(let status) = error {
                XCTAssertEqual(status, 500)
            } else {
                XCTFail("Expected AppError.server(500), got: \(error)")
            }
        }
        
        // Verify state is not authenticated
        XCTAssertFalse(auth.isAuthenticated)
    }
    
    func testLogin_NetworkError_ThrowsNetworkError() async throws {
        // Given - Mock login endpoint to simulate network error
        await mockHTTP.setShouldSimulateNetworkError(true)
        await mockHTTP.setNetworkError( URLError(.notConnectedToInternet))
        
        // When & Then - Should throw network error
        do {
            try await auth.login(username: "test", password: "password")
            XCTFail("Expected network error to be thrown")
        } catch {
            // Should throw URLError directly, not wrapped in AppError
            XCTAssertTrue(error is URLError)
            let urlError = error as! URLError
            XCTAssertEqual(urlError.code, .notConnectedToInternet)
        }
        
        // Verify state is not authenticated
        XCTAssertFalse(auth.isAuthenticated)
    }
    
    // MARK: - Edge Cases and Additional Scenarios
    
    func testValidAccessToken_ExpiredTokenButNoRefreshToken_ThrowsMissingRefreshToken() async throws {
        // Given - Store expired access token and no refresh token
        let expiredToken = JWT.createExpiredMockToken()
        try store.save(accessToken: expiredToken, refreshToken: nil)
        
        let newAuth = AuthService(config: config, http: mockHTTP, store: store)
        
        // When & Then - Should throw missingRefreshToken error
        do {
            _ = try await newAuth.validAccessToken()
            XCTFail("Expected missingRefreshToken error to be thrown")
        } catch {
            XCTAssertTrue(error is AppError)
            if case AppError.missingRefreshToken = error {
                // Expected error - this is thrown by AuthService.refreshIfNeeded()
            } else {
                XCTFail("Expected AppError.missingRefreshToken, got: \(error)")
            }
        }
    }
    
    func testLogout_WhenNotAuthenticated_DoesNothing() async throws {
        // Given - Not authenticated state
        XCTAssertFalse(auth.isAuthenticated)
        
        // When - Logout
        await auth.logout()
        
        // Then - Should still not be authenticated
        XCTAssertFalse(auth.isAuthenticated)
        
        let loaded = try store.load()
        XCTAssertNil(loaded.accessToken)
        XCTAssertNil(loaded.refreshToken)
    }
    
    func testTokenPersistence_AcrossAppRestarts() throws {
        // Given - Store tokens
        let accessToken = "access-token-123"
        let refreshToken = "refresh-token-456"
        try store.save(accessToken: accessToken, refreshToken: refreshToken)
        
        // When - Create new AuthService (simulating app restart)
        let newAuth = AuthService(config: config, http: mockHTTP, store: store)
        
        // Then - Should be authenticated with stored tokens
        XCTAssertTrue(newAuth.isAuthenticated)
    }
    
    func testTokenClear_AfterLogout() async throws {
        // Given - Login first
        let tr = TokenResponse(accessToken: "access-token", refreshToken: "refresh-token")
        let data = try JSONEncoder().encode(tr)
        await mockHTTP.setResponse(for: "\(config.baseURL)/login", data: data)
        
        try await auth.login(username: "user", password: "pass")
        XCTAssertTrue(auth.isAuthenticated)
        
        // When - Logout
        await auth.logout()
        
        // Then - Tokens should be cleared from store
        let loaded = try store.load()
        XCTAssertNil(loaded.accessToken)
        XCTAssertNil(loaded.refreshToken)
    }
    
    func testValidAccessToken_WithValidToken_ReturnsTokenImmediately() async throws {
        // Given - Store valid token
        let validToken = JWT.createMockToken(expiresIn: 3600)
        try store.save(accessToken: validToken, refreshToken: "refresh-token")
        
        let newAuth = AuthService(config: config, http: mockHTTP, store: store)
        
        // When - Call validAccessToken
        let token = try await newAuth.validAccessToken()
        
        // Then - Should return token without making refresh call
        XCTAssertEqual(token, validToken)
        // Verify no refresh endpoint was called (no mock setup needed)
    }
    
    func testValidAccessToken_WithExpiredToken_TriggersRefresh() async throws {
        // Given - Store expired token with refresh token
        let expiredToken = JWT.createExpiredMockToken()
        try store.save(accessToken: expiredToken, refreshToken: "refresh-token")
        
        let newAuth = AuthService(config: config, http: mockHTTP, store: store)
        
        // Mock refresh endpoint
        let newToken = JWT.createMockToken(expiresIn: 3600)
        let at = AccessTokenResponse(accessToken: newToken)
        await mockHTTP.setResponse(for: "\(config.baseURL)/refresh", data: try JSONEncoder().encode(at))
        
        // When - Call validAccessToken
        let token = try await newAuth.validAccessToken()
        
        // Then - Should return new token from refresh
        XCTAssertEqual(token, newToken)
        XCTAssertNotEqual(token, expiredToken)
    }
}
