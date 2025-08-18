import Foundation
import SwiftUI
import Combine
import os

// Protocol for dependency injection and testing
@MainActor
protocol AuthProviding: AnyObject, Sendable {
    var isAuthenticated: Bool { get }
    func login(username: String, password: String) async throws
    func logout() async
    func validAccessToken() async throws -> String
}

// Manages user authentication state and JWT token lifecycle
@MainActor
final class AuthService: ObservableObject, AuthProviding {
    @Published private(set) var isAuthenticated: Bool = false
    @Published var authMessage: String? = nil
    
    private let config: AppConfig
    private let http: HTTPClientProtocol
    private let store: TokenStore
    
    // JWT tokens for API authentication
    private var accessToken: String?
    private var refreshToken: String?
    
    init(config: AppConfig, http: HTTPClientProtocol, store: TokenStore) {
        self.config = config
        self.http = http
        self.store = store
        
        // Load persisted tokens from keychain
        if let loaded = try? store.load() {
            self.accessToken = loaded.accessToken
            self.refreshToken = loaded.refreshToken
            self.isAuthenticated = (loaded.accessToken != nil)
        }
    }
    
    func login(username: String, password: String) async throws {
        struct Body: Encodable { let username: String; let password: String }
        let url = URL(string: "\(config.baseURL)/login")!
        let response: TokenResponse = try await http.request(url: url, method: .post, body: Body(username: username, password: password))
        self.accessToken = response.accessToken
        self.refreshToken = response.refreshToken
        try? store.save(accessToken: accessToken, refreshToken: refreshToken)
        await MainActor.run { self.isAuthenticated = true }
    }
    
    func logout() async {
        let rt = refreshToken
        self.accessToken = nil
        self.refreshToken = nil
        try? store.clear()
        await MainActor.run { self.isAuthenticated = false }
        
        // Revoke refresh token on server for security
        if let rt {
            struct Body: Encodable { let token: String }
            let url = URL(string: "\(config.baseURL)/logout")!
            _ = try? await http.request(url: url, method: .post, body: Body(token: rt)) as EmptyResponse
        }
    }
    private let refreshGate = SingleFlight()
    
    // MARK: - Public API
    func validAccessToken() async throws -> String {
        if let token = accessToken, !JWT.isExpired(token) {
            AppLogger.info("✅ Valid Token")
            return token
        }
        
        AppLogger.info("⚠️ Token expired or missing, attempting refresh")
        try await refreshIfNeeded()
        
        if let token = accessToken { return token }
        throw AppError.unauthorized
    }
    
    // MARK: - Token refresh
    private func refreshIfNeeded() async throws {
        guard let rt = refreshToken else {
            AppLogger.error("❌ No refresh token available")
            throw AppError.missingRefreshToken
        }
        
        try await refreshGate.run {
            
            // Double-check inside critical section
            if let token = await self.accessToken, !JWT.isExpired(token) {
                AppLogger.info("✅ Token already refreshed by another task")
                return
            }
            
            AppLogger.info("🔄 Initiating token refresh")
            do {
                // Perform network request outside MainActor context
                let newAccessToken = try await self.performTokenRefresh(with: rt)
                await MainActor.run {
                    self.accessToken = newAccessToken
                    Task { try self.store.save(accessToken: self.accessToken, refreshToken: self.refreshToken) }
                }
                AppLogger.info("✅ Refresh succeeded")
            } catch {
                await self.failAuth(with: "Your session has expired. Please log in again.")
                AppLogger.error("❌ Token refresh failed: \(error.localizedDescription)")
                throw AppError.tokenRefreshFailed
            }
        }
    }
    
    // Helper method for network request
    private func performTokenRefresh(with refreshToken: String) async throws -> String {
        let url = URL(string: "\(self.config.baseURL)/refresh")!
        struct Body: Encodable, Sendable { let token: String }
        
        let response: AccessTokenResponse = try await self.http.request(
            url: url,
            method: .post,
            body: Body(token: refreshToken)
        )
        
        return response.accessToken
    }
    
    private func failAuth(with message: String) {
        self.isAuthenticated = false
        self.authMessage = message
    }
    
}


// MARK: - SingleFlight: coalesces concurrent async work Coalesces concurrent refresh operations into a single in-flight Task.
actor SingleFlight {
    private var inFlight: Task<Void, Error>?
    
    func run(_ operation: @Sendable @escaping () async throws -> Void) async throws {
        // If refresh already in progress, just await it
        if let existing = inFlight {
            try await existing.value
            return
        }
        
        let task = Task {
            defer { Task { self.clear() } } // cleanup when done
            try await operation()
        }
        inFlight = task
        
        try await task.value
    }
    
    private func clear() { inFlight = nil }
}
// For endpoints that return no data
struct EmptyResponse: Decodable {}
