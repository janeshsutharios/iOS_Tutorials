import Foundation
import Combine

// HTTP methods for type-safe requests
enum HTTPMethod: String { case get = "GET", post = "POST" }

// Protocol for dependency injection and testing (completion-based)
protocol HTTPClientProtocol {
    func request<T: Decodable, B: Encodable>(
        url: URL,
        method: HTTPMethod,
        headers: [String:String]?,
        body: B?,
        completion: @escaping (Result<T, Error>) -> Void
    )

    func request<T: Decodable>(
        url: URL,
        method: HTTPMethod,
        headers: [String:String]?,
        completion: @escaping (Result<T, Error>) -> Void
    )
}

// Convenience methods for common request patterns
extension HTTPClientProtocol {
    func request<T: Decodable>(url: URL, method: HTTPMethod = .get, headers: [String:String]? = nil, completion: @escaping (Result<T, Error>) -> Void) {
        request(url: url, method: method, headers: headers, body: Optional<Data>.none as Data?, completion: completion)
    }
    
    func request<T: Decodable, B: Encodable>(url: URL, method: HTTPMethod, body: B, completion: @escaping (Result<T, Error>) -> Void) {
        request(url: url, method: method, headers: nil, body: body, completion: completion)
    }
}

// HTTP client with automatic retry logic and timeout handling (completion-based)
final class HTTPClient: HTTPClientProtocol {
    private let session: URLSession
    private let timeout: TimeInterval
    
    init(timeout: TimeInterval) {
        self.timeout = timeout
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = timeout
        config.waitsForConnectivity = false
        self.session = URLSession(configuration: config)
    }
    
    func request<T: Decodable, B: Encodable>(
        url: URL,
        method: HTTPMethod,
        headers: [String:String]?,
        body: B?,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue
        headers?.forEach { req.setValue($1, forHTTPHeaderField: $0) }
        if let body = body {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do { req.httpBody = try JSONEncoder().encode(body) } catch { completion(.failure(AppError.decodingFailed)); return }
        }

        AppLogger.network("➡️ Request:  \(method.rawValue) \(url.absoluteString)")
        let maxRetries = 3
        var attempt = 0
        var delaySeconds: Double = 0.3

        func performRequest() {
            attempt += 1
            let task = self.session.dataTask(with: req) { data, response, error in
                if let urlErr = error as? URLError {
                    let retryable: [URLError.Code] = [.networkConnectionLost, .notConnectedToInternet, .timedOut]
                    if attempt <= maxRetries && retryable.contains(urlErr.code) {
                        DispatchQueue.global().asyncAfter(deadline: .now() + delaySeconds) {
                            delaySeconds *= 2
                            performRequest()
                        }
                        return
                    }
                    completion(.failure(AppError.network(urlErr.code)))
                    return
                } else if let error = error {
                    completion(.failure(AppError.custom(error.localizedDescription)))
                    return
                }

                guard let http = response as? HTTPURLResponse else {
                    completion(.failure(AppError.custom("No HTTPURLResponse")))
                    return
                }
                AppLogger.network("⬅️🟢 Response: \(http.statusCode) \(url.absoluteString)")

                guard let data = data else {
                    completion(.failure(AppError.custom("Empty response")))
                    return
                }

                if (200..<300).contains(http.statusCode) {
                    if T.self == EmptyResponse.self {
                        completion(.success(EmptyResponse() as! T))
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(decoded))
                    } catch {
                        completion(.failure(AppError.decodingFailed))
                    }
                } else if http.statusCode == 401 {
                    completion(.failure(AppError.unauthorized))
                } else if (500..<600).contains(http.statusCode) {
                    if attempt <= maxRetries {
                        DispatchQueue.global().asyncAfter(deadline: .now() + delaySeconds) {
                            delaySeconds *= 2
                            performRequest()
                        }
                    } else {
                        completion(.failure(AppError.server(status: http.statusCode)))
                    }
                } else {
                    completion(.failure(AppError.server(status: http.statusCode)))
                }
            }
            task.resume()
        }

        performRequest()
    }
    
    func request<T: Decodable>(
        url: URL,
        method: HTTPMethod,
        headers: [String : String]?,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        request(url: url, method: method, headers: headers, body: Optional<Data>.none as Data?, completion: completion)
    }
}
