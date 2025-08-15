//
//  AuthService.swift
//  Concurrancy1
//
//  Created by Janesh Suthar on 16/08/25.
//


import Foundation
import Combine

class AuthService: ObservableObject {
    static let shared = AuthService()
    private let baseURL = "http://localhost:3000"
    
    @Published var isAuthenticated = false
    private var accessToken: String?
    private var refreshToken: String?
    
    // Login
    func login(username: String, password: String) async throws {
        guard let url = URL(string: "\(baseURL)/login") else {
            throw NetworkError.invalidURL
        }
        
        let body = ["username": username, "password": password]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidCredentials
        }
        
        let tokens = try JSONDecoder().decode(TokenResponse.self, from: data)
        
        DispatchQueue.main.async {
            self.accessToken = tokens.accessToken
            self.refreshToken = tokens.refreshToken
            self.isAuthenticated = true
        }
    }
    
    // Refresh token
    func refreshToken() async throws {
        guard let refreshToken = refreshToken else {
            throw NetworkError.missingRefreshToken
        }
        
        guard let url = URL(string: "\(baseURL)/refresh") else {
            throw NetworkError.invalidURL
        }
        
        let body = ["token": refreshToken]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.tokenRefreshFailed
        }
        
        let tokenResponse = try JSONDecoder().decode(AccessTokenResponse.self, from: data)
        
        DispatchQueue.main.async {
            self.accessToken = tokenResponse.accessToken
        }
    }
    
    // Logout
    func logout() async throws {
        guard let refreshToken = refreshToken else { return }
        
        guard let url = URL(string: "\(baseURL)/logout") else {
            throw NetworkError.invalidURL
        }
        
        let body = ["token": refreshToken]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        _ = try await URLSession.shared.data(for: request)
        
        DispatchQueue.main.async {
            self.accessToken = nil
            self.refreshToken = nil
            self.isAuthenticated = false
        }
    }
    
    // Get auth header
    func getAuthHeader() -> [String: String]? {
        guard let token = accessToken else { return nil }
        return ["Authorization": "Bearer \(token)"]
    }
}

struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
}

struct AccessTokenResponse: Codable {
    let accessToken: String
}

enum NetworkError: Error {
    case invalidURL
    case invalidCredentials
    case missingRefreshToken
    case tokenRefreshFailed
    case unauthorized
    case unknown
}
