import Foundation

// Protocol for dependency injection and testing
protocol APIServiceProtocol {
    func fetchProfile(with token: String, completion: @escaping (Result<Profile, Error>) -> Void)
    func fetchRestaurants(with token: String, completion: @escaping (Result<[Restaurant], Error>) -> Void)
    func fetchFestivals(with token: String, completion: @escaping (Result<[Festival], Error>) -> Void)
    func fetchUsers(with token: String, completion: @escaping (Result<[User], Error>) -> Void)
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
    
    func fetchProfile(with token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        let url = URL(string: "\(config.baseURL)/profile")!
        http.request(url: url, method: .get, headers: authedHeaders(token), completion: completion)
    }
    
    func fetchRestaurants(with token: String, completion: @escaping (Result<[Restaurant], Error>) -> Void) {
        let url = URL(string: "\(config.baseURL)/restaurants")!
        http.request(url: url, method: .get, headers: authedHeaders(token), completion: completion)
    }
    
    func fetchFestivals(with token: String, completion: @escaping (Result<[Festival], Error>) -> Void) {
        let url = URL(string: "\(config.baseURL)/festivals")!
        http.request(url: url, method: .get, headers: authedHeaders(token), completion: completion)
    }
    
    func fetchUsers(with token: String, completion: @escaping (Result<[User], Error>) -> Void) {
        let url = URL(string: "\(config.baseURL)/users")!
        http.request(url: url, method: .get, headers: authedHeaders(token), completion: completion)
    }

    // Completion-based retry helper using AuthProviding
    func fetchWithRetry<T>(auth: AuthProviding, _ operation: @escaping (_ token: String, _ callback: @escaping (Result<T, Error>) -> Void) -> Void, completion: @escaping (Result<T, Error>) -> Void) {
        auth.validAccessToken { tokenResult in
            switch tokenResult {
            case .failure:
                auth.logout()
                completion(.failure(AppError.unauthorized))
            case .success(let token):
                operation(token) { opResult in
                    switch opResult {
                    case .success:
                        completion(opResult)
                    case .failure(let error):
                        if case AppError.unauthorized = error {
                            auth.logout()
                            completion(.failure(AppError.unauthorized))
                        } else {
                            completion(.failure(error))
                        }
                    }
                }
            }
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
