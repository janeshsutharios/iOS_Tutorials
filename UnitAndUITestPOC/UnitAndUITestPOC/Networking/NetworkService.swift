//
//  NetworkService.swift
//  UnitAndUITestPOC
//
//  Created by Janesh Suthar on 25/08/25.
//

import Foundation
import Combine

protocol NetworkServiceProtocol: Sendable {
    func request<T: Codable & Sendable>(_ endpoint: APIEndpoint) async throws -> T
}
protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

final class NetworkService: NetworkServiceProtocol, Sendable {
    private let session: URLSessionProtocol
    
    init(session: URLSessionProtocol) {
        self.session = session
    }
    
    func request<T: Codable & Sendable>(_ endpoint: APIEndpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header if token is provided
        if let token = endpoint.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add body for POST requests
        if let body = endpoint.body {
            request.httpBody = body
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    return decodedResponse
                } catch {
                    throw NetworkError.decodingError
                }
            case 401:
                throw NetworkError.unauthorized
            case 400...499:
                throw NetworkError.serverError(httpResponse.statusCode)
            case 500...599:
                throw NetworkError.serverError(httpResponse.statusCode)
            default:
                throw NetworkError.unknown
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error)
        }
    }
}
