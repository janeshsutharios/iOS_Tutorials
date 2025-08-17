
import XCTest
@testable import JWTClient_iOS

@MainActor
final class APIServiceTests: XCTestCase {
    var mockHTTP: MockHTTPClient!
    var config: AppConfig!
    var api: APIService!
    var store: InMemoryTokenStore!
    var auth: AuthService!

    override func setUp() {
        super.setUp()
        mockHTTP = MockHTTPClient()
        store = InMemoryTokenStore()
        config = AppConfig.load(for: .dev)
        api = APIService(config: config, http: mockHTTP)
        auth = AuthService(config: config, http: mockHTTP, store: store)
    }

    override func tearDown() {
        mockHTTP = nil; config = nil; api = nil; store = nil; auth = nil
        super.tearDown()
    }

    func testFetchDashboardData_Success_Async() async throws {
        // Prepare mock responses
        let profile = Profile(username: "alice", role: "admin")
        let restaurants = [Restaurant(id: 1, name: "R1")]
        let festivals = [Festival(id: 2, name: "F1")]
        let users = [User(id: 3, username: "bob")]

        mockHTTP.responses["\(config.baseURL)/profile"] = try JSONEncoder().encode(profile)
        mockHTTP.responses["\(config.baseURL)/restaurants"] = try JSONEncoder().encode(restaurants)
        mockHTTP.responses["\(config.baseURL)/festivals"] = try JSONEncoder().encode(festivals)
        mockHTTP.responses["\(config.baseURL)/users"] = try JSONEncoder().encode(users)

        // Ensure auth has a valid token by storing it first
        let validToken = JWT.createMockToken(expiresIn: 3600) // Valid for 1 hour
        try store.save(accessToken: validToken, refreshToken: "refresh-token")
        
        // Create a new AuthService instance to load the stored tokens
        let newAuth = AuthService(config: config, http: mockHTTP, store: store)
        let responseObj = await api.fetchDashboardDataAsync(auth: newAuth)
        if let profile = responseObj.profile,
           let restaurants = responseObj.restaurants,
           let festivals = responseObj.festivals,
           let users = responseObj.users {
            XCTAssertEqual(profile.username, "alice")
            XCTAssertEqual(restaurants.count, 1)
            XCTAssertEqual(festivals.count, 1)
            XCTAssertEqual(users.count, 1)
        }
    }
    
    func testFetchDashboardData_Success_Sync() async throws {
        // Prepare mock responses
        let profile = Profile(username: "alice", role: "admin")
        let restaurants = [Restaurant(id: 1, name: "R1")]
        let festivals = [Festival(id: 2, name: "F1")]
        let users = [User(id: 3, username: "bob")]

        mockHTTP.responses["\(config.baseURL)/profile"] = try JSONEncoder().encode(profile)
        mockHTTP.responses["\(config.baseURL)/restaurants"] = try JSONEncoder().encode(restaurants)
        mockHTTP.responses["\(config.baseURL)/festivals"] = try JSONEncoder().encode(festivals)
        mockHTTP.responses["\(config.baseURL)/users"] = try JSONEncoder().encode(users)

        // Ensure auth has a valid token by storing it first
        let validToken = JWT.createMockToken(expiresIn: 3600) // Valid for 1 hour
        try store.save(accessToken: validToken, refreshToken: "refresh-token")
        
        // Create a new AuthService instance to load the stored tokens
        let newAuth = AuthService(config: config, http: mockHTTP, store: store)
        let responseObj = await api.fetchDashboardDataSync(auth: newAuth)
        if let profile = responseObj.profile,
           let restaurants = responseObj.restaurants,
           let festivals = responseObj.festivals,
           let users = responseObj.users {
            XCTAssertEqual(profile.username, "alice")
            XCTAssertEqual(restaurants.count, 1)
            XCTAssertEqual(festivals.count, 1)
            XCTAssertEqual(users.count, 1)
        }
    }
    
    func testFetchProfile_Success() async throws {
        // Prepare mock response
        let profile = Profile(username: "testuser", role: "admin")
        mockHTTP.responses["\(config.baseURL)/profile"] = try JSONEncoder().encode(profile)
        
        // Ensure auth has a valid token
        let validToken = JWT.createMockToken(expiresIn: 3600)
        try store.save(accessToken: validToken, refreshToken: "refresh-token")
        
        let result = try await api.fetchProfile(with: validToken)
        XCTAssertEqual(result.username, "testuser")
        XCTAssertEqual(result.role, "admin")
    }
    
    func testFetchRestaurants_Success() async throws {
        // Prepare mock response
        let restaurants = [
            Restaurant(id: 1, name: "Pizza Place"),
            Restaurant(id: 2, name: "Burger Joint")
        ]
        mockHTTP.responses["\(config.baseURL)/restaurants"] = try JSONEncoder().encode(restaurants)
        
        let result = try await api.fetchRestaurants(with: "valid-token")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].name, "Pizza Place")
        XCTAssertEqual(result[1].name, "Burger Joint")
    }
    
    func testFetchFestivals_Success() async throws {
        // Prepare mock response
        let festivals = [
            Festival(id: 1, name: "Summer Music Fest"),
            Festival(id: 2, name: "Food Festival")
        ]
        mockHTTP.responses["\(config.baseURL)/festivals"] = try JSONEncoder().encode(festivals)
        
        let result = try await api.fetchFestivals(with: "valid-token")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].name, "Summer Music Fest")
        XCTAssertEqual(result[1].name, "Food Festival")
    }
    
    func testFetchUsers_Success() async throws {
        // Prepare mock response
        let users = [
            User(id: 1, username: "user1"),
            User(id: 2, username: "user2")
        ]
        mockHTTP.responses["\(config.baseURL)/users"] = try JSONEncoder().encode(users)
        
        let result = try await api.fetchUsers(with: "valid-token")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].username, "user1")
        XCTAssertEqual(result[1].username, "user2")
    }
}
