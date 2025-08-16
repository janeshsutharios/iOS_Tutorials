
import XCTest
@testable import JWTClient_iOS

@MainActor
final class AuthServiceTests: XCTestCase {
    var mockHTTP: MockHTTPClient!
    var store: InMemoryTokenStore!
    var config: AppConfig!
    var auth: AuthService!

    override func setUp() {
        super.setUp()
        mockHTTP = MockHTTPClient()
        store = InMemoryTokenStore()
        config = AppConfig.load(for: .dev)
        // Use mock HTTP and in-memory store for AuthService
        auth = AuthService(config: config, http: mockHTTP, store: store)
    }

    override func tearDown() {
        auth = nil; mockHTTP = nil; store = nil; config = nil
        super.tearDown()
    }

    func testLoginStoresTokensAndSetsAuthenticated() async throws {
        // Prepare mocked token response for login endpoint
        let tr = TokenResponse(accessToken: "access-token-xyz", refreshToken: "refresh-token-abc")
        let data = try JSONEncoder().encode(tr)
        mockHTTP.responses["\(config.baseURL)/login"] = data

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
        mockHTTP.responses["\(config.baseURL)/refresh"] = try JSONEncoder().encode(at)

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
        mockHTTP.responses["\(config.baseURL)/login"] = data
        
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
        mockHTTP.statusCode = 401 // Unauthorized
        
        // When & Then - Should throw error when refresh fails
        do {
            _ = try await newAuth.validAccessToken()
            XCTFail("Expected error to be thrown when refresh fails")
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }
}
