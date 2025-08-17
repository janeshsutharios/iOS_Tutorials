import Foundation
import Combine

// HTTP methods for type-safe requests
enum HTTPMethod: String { case get = "GET", post = "POST" }

// Protocol for dependency injection and testing
protocol HTTPClientProtocol {
    func request<T: Decodable, B: Encodable>(url: URL, method: HTTPMethod, headers: [String:String]?, body: B?) async throws -> T
    func request<T: Decodable>(url: URL, method: HTTPMethod, headers: [String:String]?) async throws -> T
}

// Convenience methods for common request patterns
extension HTTPClientProtocol {
    func request<T: Decodable>(url: URL, method: HTTPMethod = .get, headers: [String:String]? = nil) async throws -> T {
        try await request(url: url, method: method, headers: headers, body: Optional<Data>.none as Data?)
    }
    
    func request<T: Decodable, B: Encodable>(url: URL, method: HTTPMethod, body: B) async throws -> T {
        try await request(url: url, method: method, headers: nil, body: body)
    }
}

// HTTP client with automatic retry logic and timeout handling
final class HTTPClient: HTTPClientProtocol {
    private let session: URLSession
    private let timeout: TimeInterval
    
    init(timeout: TimeInterval) {
        self.timeout = timeout
        // Configure ephemeral session for better security and performance
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = timeout
        config.waitsForConnectivity = true  // Wait for network to become available
        self.session = URLSession(configuration: config)
    }
    
    func request<T: Decodable, B: Encodable>(url: URL, method: HTTPMethod, headers: [String:String]?, body: B?) async throws -> T {

        // Build URLRequest with method, headers, and body
        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue
        headers?.forEach { req.setValue($1, forHTTPHeaderField: $0) }
        if let body = body {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try JSONEncoder().encode(body)
        }

        // Log network request for debugging
        AppLogger.network("➡️ Request:  \(method.rawValue) \(url.absoluteString)")
       //  AppLogger.network(headers?.description ?? "No headers")
        // Retry configuration with exponential backoff
        let maxRetries = 3
        var delay: UInt64 = 300_000_000 // Start with 0.3 seconds (300ms)
        var attempt = 0

        while true {
            attempt += 1
            do {
                // Make the actual network request
                let (data, response): (Data, URLResponse)
                do {
                    (data, response) = try await self.session.data(for: req)
                } catch let urlErr as URLError where urlErr.code == .timedOut {
                    AppLogger.network("Timeout: \(url.absoluteString)")
                    throw AppError.timeout
                    
                } catch let urlErr as URLError where urlErr.code == .cancelled {
                    AppLogger.network( "API-Cancelled: \(urlErr.localizedDescription)")
                    throw AppError.network(urlErr.code)
                }

                guard let http = response as? HTTPURLResponse else {
                    throw AppError.unknown("No HTTPURLResponse")
                }
                
                AppLogger.network("⬅️🟢 Response: \(http.statusCode) \(url.absoluteString)")
                
                // Handle successful responses (2xx status codes)
                if (200..<300).contains(http.statusCode) {
                    if T.self == EmptyResponse.self {
                        return EmptyResponse() as! T
                    }
                    do {
                        return try JSONDecoder().decode(T.self, from: data)
                    } catch {
                        throw AppError.decodingFailed
                    }
                } else if http.statusCode == 401 {
                    // Unauthorized - don't retry, throw immediately
                    throw AppError.unauthorized
                } else if (500..<600).contains(http.statusCode) {
                    // Server errors (5xx) - retry with exponential backoff
                    if attempt <= maxRetries {
                        try await Task.sleep(nanoseconds: delay)
                        delay *= 2  // Double the delay for next attempt
                        continue // Means code will not execute below this line.
                    }
                    throw AppError.server(status: http.statusCode)
                } else {
                    // Client errors (4xx) - don't retry, throw immediately
                    throw AppError.server(status: http.statusCode)
                }
            } catch {
                // Handle various error types and determine retry strategy
                if let urlErr = error as? URLError {
                    // Network-level errors that might be transient
                    let retryableCodes: [URLError.Code] = [
                        .networkConnectionLost,      // Connection dropped
                        .notConnectedToInternet,    // No internet
                        .timedOut                   // Request timeout
                    ]
                    
                    if attempt <= maxRetries && retryableCodes.contains(urlErr.code) {
                        // Retry network errors with exponential backoff
                        try await Task.sleep(nanoseconds: delay)
                        delay *= 2
                        continue
                    }
                    throw AppError.network(urlErr.code)
                } else if let appErr = error as? AppError {
                    // Re-throw app-specific errors
                    throw appErr
                } else if error is DecodingError {
                    // JSON parsing failed - don't retry
                    throw AppError.decodingFailed
                } else {
                    // Unknown errors - wrap in AppError
                    throw AppError.unknown(error.localizedDescription)
                }
            }
        }
    }
}
