import Foundation

final class MockHTTPClient: HTTPClientProtocol {
    var responses: [String: Data] = [:]
    var statusCode: Int = 200
    
    func request<T, B>(url: URL, method: HTTPMethod, headers: [String : String]?, body: B?) async throws -> T where T : Decodable, B : Encodable {
        if statusCode == 401 { throw AppError.unauthorized }
        if statusCode >= 500 { throw AppError.server(status: statusCode) }
        let key = url.absoluteString
        let data = responses[key] ?? Data("{}".utf8)
        return try JSONDecoder().decode(T.self, from: data)
    }
    func request<T>(url: URL, method: HTTPMethod, headers: [String : String]?) async throws -> T where T : Decodable {
        try await request(url: url, method: method, headers: headers, body: Optional<Data>.none as Data?)
    }
}

final class InMemoryTokenStore: TokenStore {
    private var a: String?; private var r: String?
    func save(accessToken: String?, refreshToken: String?) throws { a = accessToken; r = refreshToken }
    func load() throws -> (accessToken: String?, refreshToken: String?) { (a, r) }
    func clear() throws { a = nil; r = nil }
}

// MARK: - JWT Token Helper for Testing
extension JWT {
    /// Creates a mock JWT token for testing purposes
    /// This creates a valid JWT structure that can be decoded
    static func createMockToken(expiresIn: TimeInterval = 3600) -> String {
        let header = ["alg": "HS256", "typ": "JWT"]
        let payload = [
            "sub": "test-user",
            "iat": Date().timeIntervalSince1970,
            "exp": Date().addingTimeInterval(expiresIn).timeIntervalSince1970
        ] as [String : Any]
        
        let headerData = try! JSONSerialization.data(withJSONObject: header)
        let headerBase64 = headerData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        
        let payloadData = try! JSONSerialization.data(withJSONObject: payload)
        let payloadBase64 = payloadData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        
        // Mock signature (not cryptographically valid, just for testing)
        let signature = "mock-signature-for-testing"
        let signatureBase64 = signature.data(using: .utf8)!.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        
        return "\(headerBase64).\(payloadBase64).\(signatureBase64)"
    }
    
    /// Creates an expired mock JWT token for testing
    static func createExpiredMockToken() -> String {
        return createMockToken(expiresIn: -3600) // Expired 1 hour ago
    }
}
