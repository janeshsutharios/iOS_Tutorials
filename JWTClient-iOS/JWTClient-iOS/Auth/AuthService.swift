import Foundation
import SwiftUI
import Combine

struct TokenResponse: Codable { let accessToken: String; let refreshToken: String }
struct AccessTokenResponse: Codable { let accessToken: String }

protocol AuthProviding: AnyObject {
    var isAuthenticated: Bool { get }
    func login(username: String, password: String) async throws
    func logout() async
    func validAccessToken() async throws -> String
}

final class AuthService: ObservableObject, AuthProviding {
    @Published private(set) var isAuthenticated: Bool = false
    
    private let config: AppConfig
    private let http: HTTPClientProtocol
    private let store: TokenStore
    
    private var accessToken: String?
    private var refreshToken: String?
    
    init(config: AppConfig, http: HTTPClientProtocol, store: TokenStore) {
        self.config = config
       // this = self
        self.http = http
        self.store = store
        
        // Load persisted tokens
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
        
        if let rt {
            struct Body: Encodable { let token: String }
            let url = URL(string: "\(config.baseURL)/logout")!
            _ = try? await http.request(url: url, method: .post, body: Body(token: rt)) as EmptyResponse
        }
    }
    
    func validAccessToken() async throws -> String {
        if let token = accessToken, !JWT.isExpired(token) {
            return token
        }
        try await refreshIfNeeded()
        if let token = accessToken { return token }
        throw AppError.unauthorized
    }
    
    private func refreshIfNeeded() async throws {
        guard let rt = refreshToken else { throw AppError.missingRefreshToken }
        let url = URL(string: "\(config.baseURL)/refresh")!
        struct Body: Encodable { let token: String }
        let response: AccessTokenResponse = try await http.request(url: url, method: .post, body: Body(token: rt))
        self.accessToken = response.accessToken
        try? store.save(accessToken: accessToken, refreshToken: refreshToken)
    }
}

// For endpoints that return no data
struct EmptyResponse: Decodable {}
