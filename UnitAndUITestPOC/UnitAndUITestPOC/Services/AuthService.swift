//
//  AuthService.swift
//  UnitAndUITestPOC
//
//  Created by Janesh Suthar on 25/08/25.
//

import Foundation
import Combine

protocol AuthServiceProtocol: Sendable {
    func login(username: String, password: String) async throws -> LoginResponse
}

actor AuthService: AuthServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func login(username: String, password: String) async throws -> LoginResponse {
        let loginRequest = LoginRequest(username: username, password: password)
        let endpoint = APIEndpoint.login(loginRequest)
        
        return try await networkService.request(endpoint)
    }
}
