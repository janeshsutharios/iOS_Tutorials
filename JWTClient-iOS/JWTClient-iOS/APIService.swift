//
//  APIService.swift
//  Concurrancy1
//
//  Created by Janesh Suthar on 16/08/25.
//


import Foundation
import Combine

class APIService {
    static let shared = APIService()
    private let baseURL = "http://localhost:3000"
    
    // Generic request with token handling
    private func makeAuthenticatedRequest<T: Decodable>(url: URL) async throws -> T {
        guard let headers = AuthService.shared.getAuthHeader() else {
            throw NetworkError.unauthorized
        }
        
        var request = URLRequest(url: url)
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                // Token expired, try to refresh
                try await AuthService.shared.refreshToken()
                return try await makeAuthenticatedRequest(url: url) // Retry with new token
            }
            
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw error
        }
    }
    
    // Fetch profile
    func fetchProfile() async throws -> Profile {
        guard let url = URL(string: "\(baseURL)/profile") else {
            throw NetworkError.invalidURL
        }
        return try await makeAuthenticatedRequest(url: url)
    }
    
    // Fetch restaurants
    func fetchRestaurants() async throws -> [Restaurant] {
        guard let url = URL(string: "\(baseURL)/restaurants") else {
            throw NetworkError.invalidURL
        }
        return try await makeAuthenticatedRequest(url: url)
    }
    
    // Fetch festivals
    func fetchFestivals() async throws -> [Festival] {
        guard let url = URL(string: "\(baseURL)/festivals") else {
            throw NetworkError.invalidURL
        }
        return try await makeAuthenticatedRequest(url: url)
    }
    
    // Fetch users
    func fetchUsers() async throws -> [User] {
        guard let url = URL(string: "\(baseURL)/users") else {
            throw NetworkError.invalidURL
        }
        return try await makeAuthenticatedRequest(url: url)
    }
    
    // Fetch all dashboard data concurrently
    func fetchDashboardData() async throws -> DashboardData {
        async let profile = fetchProfile()
        async let restaurants = fetchRestaurants()
        async let festivals = fetchFestivals()
        async let users = fetchUsers()
        
        return try await DashboardData(
            profile: profile,
            restaurants: restaurants,
            festivals: festivals,
            users: users
        )
    }
}

// Data Models
struct Profile: Codable {
    let username: String
    let role: String
}

struct Restaurant: Codable, Identifiable {
    let id: Int
    let name: String
}

struct Festival: Codable, Identifiable {
    let id: Int
    let name: String
}

struct User: Codable, Identifiable {
    let id: Int
    let username: String
}

struct DashboardData {
    let profile: Profile
    let restaurants: [Restaurant]
    let festivals: [Festival]
    let users: [User]
}
