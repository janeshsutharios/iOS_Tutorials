//
//  AuthModelsTests.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import XCTest
@testable import UnitAndUITestPOC

final class AuthModelsTests: XCTestCase {
    
    func testLoginRequestEncoding() throws {
        // Given
        let loginRequest = LoginRequest(username: "testuser", password: "testpass")
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(loginRequest)
        let jsonString = String(data: data, encoding: .utf8)
        
        // Then
        XCTAssertNotNil(jsonString)
        XCTAssertTrue(jsonString?.contains("testuser") ?? false)
        XCTAssertTrue(jsonString?.contains("testpass") ?? false)
    }
    
    func testLoginRequestDecoding() throws {
        // Given
        let jsonString = """
        {
            "username": "testuser",
            "password": "testpass"
        }
        """
        let data = jsonString.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let loginRequest = try decoder.decode(LoginRequest.self, from: data)
        
        // Then
        XCTAssertEqual(loginRequest.username, "testuser")
        XCTAssertEqual(loginRequest.password, "testpass")
    }
    
    func testLoginResponseEncoding() throws {
        // Given
        let loginResponse = LoginResponse(
            accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9",
            refreshToken: "refresh123"
        )
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(loginResponse)
        let jsonString = String(data: data, encoding: .utf8)
        
        // Then
        XCTAssertNotNil(jsonString)
        XCTAssertTrue(jsonString?.contains("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9") ?? false)
        XCTAssertTrue(jsonString?.contains("refresh123") ?? false)
    }
    
    func testLoginResponseDecoding() throws {
        // Given
        let jsonString = """
        {
            "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9",
            "refreshToken": "refresh123"
        }
        """
        let data = jsonString.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let loginResponse = try decoder.decode(LoginResponse.self, from: data)
        
        // Then
        XCTAssertEqual(loginResponse.accessToken, "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9")
        XCTAssertEqual(loginResponse.refreshToken, "refresh123")
    }
    
    func testAuthStateEquality() {
        // Given & When & Then
        XCTAssertEqual(AuthState.idle, AuthState.idle)
        XCTAssertEqual(AuthState.loading, AuthState.loading)
        XCTAssertEqual(AuthState.authenticated, AuthState.authenticated)
        XCTAssertEqual(AuthState.error("test"), AuthState.error("test"))
        XCTAssertNotEqual(AuthState.error("test1"), AuthState.error("test2"))
    }
}
