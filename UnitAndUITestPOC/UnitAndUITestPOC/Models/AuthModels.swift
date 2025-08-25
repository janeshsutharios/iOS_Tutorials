//
//  AuthModels.swift
//  UnitAndUITestPOC
//
//  Created by Janesh Suthar on 25/08/25.
//

import Foundation

// MARK: - Login Request
struct LoginRequest: Codable, Sendable {
    let username: String
    let password: String
}

// MARK: - Login Response
struct LoginResponse: Codable, Sendable {
    let accessToken: String
    let refreshToken: String
    nonisolated init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accessToken = try container.decode(String.self, forKey: .accessToken)
        self.refreshToken = try container.decode(String.self, forKey: .refreshToken)
    }
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

// MARK: - Auth State
enum AuthState: Equatable, Sendable {
    case idle
    case loading
    case authenticated
    case error(String)
}
