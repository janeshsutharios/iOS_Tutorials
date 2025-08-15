import Foundation

protocol APIServiceProtocol {
    func fetchProfile(with token: String) async throws -> Profile
    func fetchRestaurants(with token: String) async throws -> [Restaurant]
    func fetchFestivals(with token: String) async throws -> [Festival]
    func fetchUsers(with token: String) async throws -> [User]
    func fetchDashboardData(auth: AuthProviding) async throws -> DashboardData
}

final class APIService: APIServiceProtocol {
    private let config: AppConfig
    private let http: HTTPClientProtocol
    
    init(config: AppConfig, http: HTTPClientProtocol) {
        self.config = config
        self.http = http
    }
    
    private func authedHeaders(_ token: String) -> [String:String] {
        ["Authorization": "Bearer \(token)"]
    }
    
    func fetchProfile(with token: String) async throws -> Profile {
        let url = URL(string: "\(config.baseURL)/profile")!
        return try await http.request(url: url, method: .get, headers: authedHeaders(token))
    }
    func fetchRestaurants(with token: String) async throws -> [Restaurant] {
        let url = URL(string: "\(config.baseURL)/restaurants")!
        return try await http.request(url: url, method: .get, headers: authedHeaders(token))
    }
    func fetchFestivals(with token: String) async throws -> [Festival] {
        let url = URL(string: "\(config.baseURL)/festivals")!
        return try await http.request(url: url, method: .get, headers: authedHeaders(token))
    }
    func fetchUsers(with token: String) async throws -> [User] {
        let url = URL(string: "\(config.baseURL)/users")!
        return try await http.request(url: url, method: .get, headers: authedHeaders(token))
    }
    
    func fetchDashboardData(auth: AuthProviding) async throws -> DashboardData {
        let token = try await auth.validAccessToken()
        async let profile = fetchProfile(with: token)
        async let restaurants = fetchRestaurants(with: token)
        async let festivals = fetchFestivals(with: token)
        async let users = fetchUsers(with: token)
        return try await .init(profile: profile, restaurants: restaurants, festivals: festivals, users: users)
    }
}
