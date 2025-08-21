import Foundation
import SwiftUI
import Combine
import os

// Protocol for dependency injection and testing (completion-based)
protocol AuthProviding: AnyObject {
    var isAuthenticated: Bool { get }
    func login(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
    func logout()
    func validAccessToken(completion: @escaping (Result<String, Error>) -> Void)
}

// Manages user authentication state and JWT token lifecycle (completion-based)
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
        
        if let loaded = try? store.load() {
            self.accessToken = loaded.accessToken
            self.refreshToken = loaded.refreshToken
            self.isAuthenticated = (loaded.accessToken != nil)
        }
    }
    
    func login(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: "\(config.baseURL)/login")!
        http.request(url: url, method: .post, body: LoginBody(username: username, password: password)) { (result: Result<TokenResponse, Error>) in
            switch result {
            case .success(let response):
                self.accessToken = response.accessToken
                self.refreshToken = response.refreshToken
                try? self.store.save(accessToken: self.accessToken, refreshToken: self.refreshToken)
                DispatchQueue.main.async { self.isAuthenticated = true }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func logout() {
        let rt = refreshToken
        self.accessToken = nil
        self.refreshToken = nil
        try? store.clear()
        DispatchQueue.main.async { self.isAuthenticated = false }
        
        if let rt {
            let url = URL(string: "\(config.baseURL)/logout")!
            http.request(url: url, method: .post, body: TokenBody(token: rt)) { (_: Result<EmptyResponse, Error>) in }
        }
    }
    
    private let refreshGate = RefreshGate()
    
    func validAccessToken(completion: @escaping (Result<String, Error>) -> Void) {
        if let token = accessToken, !JWT.isExpired(token) {
            AppLogger.info("✅ Valid Token")
            completion(.success(token))
            return
        }
        AppLogger.info("⚠️ Token expired or missing, attempting refresh")
        refreshIfNeeded { result in
            switch result {
            case .success:
                if let token = self.accessToken { completion(.success(token)) } else { completion(.failure(AppError.unauthorized)) }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func refreshIfNeeded(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let rt = refreshToken else {
            AppLogger.error("❌ No refresh token available")
            completion(.failure(AppError.missingRefreshToken))
            return
        }
        
        refreshGate.run({ done in
            // Double-check inside critical section
            if let token = self.accessToken, !JWT.isExpired(token) {
                AppLogger.info("✅ Token already refreshed by another task")
                done(.success(()))
                return
            }
            AppLogger.info("🔄 Initiating token refresh")
            self.performTokenRefresh(with: rt) { result in
                switch result {
                case .success(let newAccessToken):
                    self.accessToken = newAccessToken
                    try? self.store.save(accessToken: self.accessToken, refreshToken: self.refreshToken)
                    AppLogger.info("✅ Refresh succeeded")
                    done(.success(()))
                case .failure:
                    self.failAuth(with: "Your session has expired. Please log in again.")
                    AppLogger.error("❌ Token refresh failed")
                    done(.failure(AppError.tokenRefreshFailed))
                }
            }
        }, completion: completion)
    }
    
    private func performTokenRefresh(with refreshToken: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "\(self.config.baseURL)/refresh")!
        struct Body: Codable { let token: String }
        http.request(url: url, method: .post, body: Body(token: refreshToken)) { (result: Result<AccessTokenResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.accessToken))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func failAuth(with message: String) {
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.authMessage = message
        }
    }
}

// Coalesce concurrent refresh operations
final class RefreshGate {
    private let queue = DispatchQueue(label: "AuthService.RefreshGate")
    private var inFlight = false
    private var waiters: [(Result<Void, Error>) -> Void] = []
    
    func run(_ operation: @escaping (@escaping (Result<Void, Error>) -> Void) -> Void, completion: @escaping (Result<Void, Error>) -> Void) {
        var shouldStart = false
        queue.sync {
            if inFlight {
                waiters.append(completion)
            } else {
                inFlight = true
                waiters.append(completion)
                shouldStart = true
            }
        }
        guard shouldStart else { return }
        operation { result in
            var callbacks: [(Result<Void, Error>) -> Void] = []
            self.queue.sync {
                callbacks = self.waiters
                self.waiters.removeAll()
                self.inFlight = false
            }
            callbacks.forEach { $0(result) }
        }
    }
}
