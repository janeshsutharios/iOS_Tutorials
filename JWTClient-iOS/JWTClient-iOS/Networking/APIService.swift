import Foundation

// Protocol for dependency injection and testing
protocol APIServiceProtocol {
    func fetchProfile(with token: String) async throws -> Profile
    func fetchRestaurants(with token: String) async throws -> [Restaurant]
    func fetchFestivals(with token: String) async throws -> [Festival]
    func fetchUsers(with token: String) async throws -> [User]
    func fetchDashboardData(auth: AuthProviding) async throws -> DashboardData
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
    /* Problem with below function is -
     
     With async let, one failure = all cancelled.
     That’s by design (structured concurrency is “all-or-nothing”).
     
    // Fetch all dashboard data concurrently for optimal performance
    func fetchDashboardData(auth: AuthProviding) async throws -> DashboardData {
        let token = try await auth.validAccessToken()
        async let profile = fetchProfile(with: token)
        async let restaurants = fetchRestaurants(with: token)
        async let festivals = fetchFestivals(with: token)
        async let users = fetchUsers(with: token)
        return try await .init(profile: profile, restaurants: restaurants, festivals: festivals, users: users)
    }
    */
    
    func fetchDashboardData(auth: AuthProviding) async throws -> DashboardData {
        var token = try await auth.validAccessToken()
        
        // Build tasks
        func makeTasks(with token: String) -> [ResilientTask<String, Any>] {
            [
                ResilientTask(id: "profile") {
                    try await self.fetchProfile(with: token)
                },
                ResilientTask(id: "restaurants") {
                    try await self.fetchRestaurants(with: token)
                },
                ResilientTask(id: "festivals") {
                    try await self.fetchFestivals(with: token)
                },
                ResilientTask(id: "users") {
                    try await self.fetchUsers(with: token)
                }
            ]
        }
        
        let (successes, failures) = await ResilientTaskGroup.run(
            tasks: makeTasks(with: token)
        ) { failedTasks in
            // If failure → refresh token & rebuild failed tasks with new token
            token = try! await auth.validAccessToken()
            return makeTasks(with: token).filter { task in
                failedTasks.contains { $0.id == task.id }
            }
        }
        
        // If still failures, throw a partial error
        if !failures.isEmpty {
            throw AppError.partialFailure(failures.keys.map { $0 })
        }
        
        return DashboardData(
            profile: successes["profile"] as! Profile,
            restaurants: successes["restaurants"] as! [Restaurant],
            festivals: successes["festivals"] as! [Festival],
            users: successes["users"] as! [User]
        )
    }

}
