//
//  AuthService.swift
//  UnitAndUITestPOC
//
//  Created by Janesh Suthar on 25/08/25.
//

import Foundation

protocol AuthServiceProtocol {
    func login(username: String, password: String) async throws -> LoginResponse
}

class AuthService: AuthServiceProtocol {
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
