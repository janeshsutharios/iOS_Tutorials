import Foundation

// Protocol for dependency injection and testing
protocol APIServiceProtocol {
    func fetchProfile(with token: String) async throws -> Profile
    func fetchRestaurants(with token: String) async throws -> [Restaurant]
    func fetchFestivals(with token: String) async throws -> [Festival]
    func fetchUsers(with token: String) async throws -> [User]
    func fetchDashboardDataAsync(auth: AuthProviding) async throws -> DashboardData
    func fetchDashboardDataSync(auth: AuthProviding) async throws -> DashboardData

}

// Service for making authenticated API calls to backend endpoints
final class APIService: APIServiceProtocol {
    private let config: AppConfig
    private let http: HTTPClientProtocol
    
    init(config: AppConfig, http: HTTPClientProtocol) {
        self.config = config
        self.http = http
    }
    
    // Create Bearer token headers for authenticated requests
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
    
    /// Runs operation with one retry if unauthorized
    func fetchWithRetry<T>(auth: AuthProviding,_ operation: @escaping (_ token: String) async throws -> T) async -> Result<T, Error> {
        
        do {
            let newToken = try await auth.validAccessToken()
            return .success(try await operation(newToken))
        } catch AppError.unauthorized {
            // Token is invalid/expired and refresh failed - logout user
            await auth.logout()
            return .failure(AppError.unauthorized)
        } catch {
            return .failure(error)
        }
        
    }
    /*
     Problem with below function is - With async let, one failure = all cancelled. That’s by design (structured concurrency is “all-or-nothing”).
     To overcome multiple webcall with token issue I have moved fetchDashboardData into seperate files i.e. AsyncCallsManage & SyncCallManage
    func fetchDashboardData(auth: AuthProviding) async throws -> DashboardData {
        let token = try await auth.validAccessToken()
        async let profile = fetchProfile(with: token)
        async let restaurants = fetchRestaurants(with: token)
        async let festivals = fetchFestivals(with: token)
        async let users = fetchUsers(with: token)
        return try await .init(profile: profile, restaurants: restaurants, festivals: festivals, users: users)
    }
    */
}
