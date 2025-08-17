import Foundation

struct Profile: Codable, Sendable { let username: String; let role: String }
struct Restaurant: Codable, Sendable, Identifiable { let id: Int; let name: String }
struct Festival: Codable, Sendable, Identifiable { let id: Int; let name: String }
struct User: Codable, Sendable, Identifiable { let id: Int; let username: String }

struct DashboardData: Sendable {
    var profile: Profile?
    var restaurants: [Restaurant]?
    var festivals: [Festival]?
    var users: [User]?
    
    var errors: [String: Error] = [:] // keep track of what failed
}

// Response models for authentication endpoints
struct TokenResponse: Codable, Sendable {
    let accessToken: String;
    let refreshToken: String
}


struct AccessTokenResponse: Codable, Sendable {
    let accessToken: String
}
