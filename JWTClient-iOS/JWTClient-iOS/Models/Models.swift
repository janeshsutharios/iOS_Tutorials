import Foundation

struct DashboardData: Sendable {
    var profile: Profile?
    var restaurants: [Restaurant]?
    var festivals: [Festival]?
    var users: [User]?
    
    var errors: [String: Error] = [:] // keep track of what failed
}

struct LoginBody: Codable, Sendable {
    let username: String
    let password: String

    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(username, forKey: .username)
        try container.encode(password, forKey: .password)
    }
}

struct TokenBody: Codable, Sendable {
    let token: String
    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(token, forKey: .token)
    }
}

struct Profile: Codable, Sendable {
    let username: String
    let role: String
    // Answer to nonisolated
   // “Decoding Profile is not tied to the main actor. It’s thread-safe and safe to use anywhere.”
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        username = try container.decode(String.self, forKey: .username)
        role = try container.decode(String.self, forKey: .role)
    }
    init(username: String, role: String) {
        self.username = username
        self.role = role
    }
}
struct Restaurant: Codable, Sendable, Identifiable {
    let id: Int
    let name: String
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
    }
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

struct Festival: Codable, Sendable, Identifiable {
    let id: Int
    let name: String

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
    }
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

struct User: Codable, Sendable, Identifiable {
    let id: Int
    let username: String

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
    }
    init(id: Int, username: String) {
        self.id = id
        self.username = username
    }
}

// Response models for authentication endpoints
struct TokenResponse: Codable, Sendable {
    let accessToken: String
    let refreshToken: String

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try container.decode(String.self, forKey: .accessToken)
        refreshToken = try container.decode(String.self, forKey: .refreshToken)
    }
    
    init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}

struct AccessTokenResponse: Codable, Sendable {
    let accessToken: String

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try container.decode(String.self, forKey: .accessToken)
    }
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
}
// For endpoints that return no data
struct EmptyResponse: Decodable, Sendable {
    nonisolated init(from decoder: Decoder) throws {}
    init() {}
}
