//
//  AuthModels.swift
//  UnitAndUITestPOC
//
//  Created by Janesh Suthar on 25/08/25.
//

import Foundation

// MARK: - Login Request
struct LoginRequest: Codable {
    let username: String
    let password: String
}

// MARK: - Login Response
struct LoginResponse: Codable {
    let accessToken: String
    let refreshToken: String
}

// MARK: - Auth State
enum AuthState {
    case idle
    case loading
    case authenticated
    case error(String)
}
