import Foundation
import Combine

enum HTTPMethod: String { case get = "GET", post = "POST" }

protocol HTTPClientProtocol {
    func request<T: Decodable, B: Encodable>(url: URL, method: HTTPMethod, headers: [String:String]?, body: B?) async throws -> T
    func request<T: Decodable>(url: URL, method: HTTPMethod, headers: [String:String]?) async throws -> T
}

extension HTTPClientProtocol {
    func request<T: Decodable>(url: URL, method: HTTPMethod = .get, headers: [String:String]? = nil) async throws -> T {
        try await request(url: url, method: method, headers: headers, body: Optional<Data>.none as Data?)
    }
    func request<T: Decodable, B: Encodable>(url: URL, method: HTTPMethod, body: B) async throws -> T {
        try await request(url: url, method: method, headers: nil, body: body)
    }
}


final class HTTPClient: HTTPClientProtocol {
    private let session: URLSession
    private let timeout: TimeInterval
    
    init(timeout: TimeInterval) {
        self.timeout = timeout
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = timeout
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
    }
    
    func request<T: Decodable, B: Encodable>(url: URL, method: HTTPMethod, headers: [String:String]?, body: B?) async throws -> T {
        // Simple network logging
        AppLogger.network("\(method.rawValue) \(url.absoluteString)")
        
        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue
        headers?.forEach { req.setValue($1, forHTTPHeaderField: $0) }
        if let body = body {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try JSONEncoder().encode(body)
        }

        let maxRetries = 3
        var delay: UInt64 = 300_000_000 // 0.3s
        var attempt = 0

        while true {
            attempt += 1
            do {
                // ✅ Simple, reliable timeout via URLSession config
                let (data, response): (Data, URLResponse)
                do {
                    (data, response) = try await self.session.data(for: req)
                } catch let urlErr as URLError where urlErr.code == .timedOut {
                    AppLogger.network("Timeout: \(url.absoluteString)")
                    throw AppError.timeout
                }

                guard let http = response as? HTTPURLResponse else { throw AppError.unknown("No HTTPURLResponse") }
                
                // Log response status
                AppLogger.network("Response: \(http.statusCode) \(url.absoluteString)")
                
                if (200..<300).contains(http.statusCode) {
                    if T.self == EmptyResponse.self { return EmptyResponse() as! T }
                    do { return try JSONDecoder().decode(T.self, from: data) }
                    catch { throw AppError.decodingFailed }
                } else if http.statusCode == 401 {
                    throw AppError.unauthorized
                } else if (500..<600).contains(http.statusCode) {
                    if attempt <= maxRetries {
                        try await Task.sleep(nanoseconds: delay)
                        delay *= 2
                        continue
                    }
                    throw AppError.server(status: http.statusCode)
                } else {
                    throw AppError.server(status: http.statusCode)
                }
            } catch {
                if let urlErr = error as? URLError {
                    if attempt <= maxRetries && (urlErr.code == .networkConnectionLost || urlErr.code == .notConnectedToInternet || urlErr.code == .timedOut) {
                        try await Task.sleep(nanoseconds: delay)
                        delay *= 2
                        continue
                    }
                    throw AppError.network(urlErr.code)
                } else if let appErr = error as? AppError {
                    throw appErr
                } else if error is DecodingError {
                    throw AppError.decodingFailed
                } else {
                    throw AppError.unknown(error.localizedDescription)
                }
            }
        }
    }
}
