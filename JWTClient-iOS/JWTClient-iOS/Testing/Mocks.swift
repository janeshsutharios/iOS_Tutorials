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
