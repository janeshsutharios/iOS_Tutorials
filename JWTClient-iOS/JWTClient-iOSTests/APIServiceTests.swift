
import XCTest
@testable import JWTClient_iOS

@MainActor
final class APIServiceTests: XCTestCase {
    var mockHTTP: MockHTTPClient!
    var config: AppConfig!
    var api: APIService!
    var store: InMemoryTokenStore!
    var auth: AuthService!

    override func setUp() async throws {
       // try await super.setUp()
        mockHTTP = MockHTTPClient()
        store = InMemoryTokenStore()
        config = AppConfig.load(for: .dev)
        api = APIService(config: config, http: mockHTTP)
        auth = AuthService(config: config, http: mockHTTP, store: store)
    }

    override func tearDown() async throws {
        mockHTTP = nil; config = nil; api = nil; store = nil; auth = nil
    }

    func testFetchDashboardData_Success_Async() async throws {
        let auth = try await setupDashboardMocks()
        let responseObj = await api.fetchDashboardDataAsync(auth: auth)
        assertDashboardResponse(responseObj)
    }

    func testFetchDashboardData_Success_Sync() async throws {
        let auth = try await setupDashboardMocks()
        let responseObj = await api.fetchDashboardDataSync(auth: auth)
        assertDashboardResponse(responseObj)
    }

    func testFetchProfile_Success() async throws {
        // Prepare mock response
        let profile = Profile(username: "testuser", role: "admin")
        await mockHTTP.setResponse(for: "\(config.baseURL)/profile", data: try JSONEncoder().encode(profile))

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
        await mockHTTP.setResponse(for: "\(config.baseURL)/restaurants", data: try JSONEncoder().encode(restaurants))

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
        await mockHTTP.setResponse(for: "\(config.baseURL)/festivals", data: try JSONEncoder().encode(festivals))

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
        await mockHTTP.setResponse(for: "\(config.baseURL)/users", data: try JSONEncoder().encode(users))

        let result = try await api.fetchUsers(with: "valid-token")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].username, "user1")
        XCTAssertEqual(result[1].username, "user2")
    }
}

extension APIServiceTests {
    
    private func setupDashboardMocks() async throws -> AuthService {
        let profile = Profile(username: "alice", role: "admin")
        let restaurants = [Restaurant(id: 1, name: "R1")]
        let festivals = [Festival(id: 2, name: "F1")]
        let users = [User(id: 3, username: "bob")]
        
        await mockHTTP.setResponse(for: "\(config.baseURL)/profile", data: try JSONEncoder().encode(profile))

        await mockHTTP.setResponse(for: "\(config.baseURL)/restaurants", data: try JSONEncoder().encode(restaurants))

        await mockHTTP.setResponse(for: "\(config.baseURL)/festivals", data: try JSONEncoder().encode(festivals))

        await mockHTTP.setResponse(for: "\(config.baseURL)/users", data: try JSONEncoder().encode(users))

        // Valid token
        let validToken = JWT.createMockToken(expiresIn: 3600)
        try store.save(accessToken: validToken, refreshToken: "refresh-token")

        // New AuthService to simulate reload
        return AuthService(config: config, http: mockHTTP, store: store)
    }
    
    private func assertDashboardResponse(_ responseObj: DashboardData) {
        XCTAssertEqual(responseObj.profile?.username, "alice")
        XCTAssertEqual(responseObj.restaurants?.count, 1)
        XCTAssertEqual(responseObj.festivals?.count, 1)
        XCTAssertEqual(responseObj.users?.count, 1)
    }
}
