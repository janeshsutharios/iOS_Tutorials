//
//  AuthModelsSwiftTests.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import Testing
@testable import UnitAndUITestPOC

@Suite("Authentication Models")
struct AuthModelsSwiftTests {
    
    @Test("LoginRequest encoding produces valid JSON")
    func testLoginRequestEncoding() throws {
        let loginRequest = LoginRequest(username: "testuser", password: "testpass")
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(loginRequest)
        let jsonString = String(data: data, encoding: .utf8)
        
        #expect(jsonString != nil)
        #expect(jsonString?.contains("testuser") == true)
        #expect(jsonString?.contains("testpass") == true)
    }
    
    @Test("LoginRequest decoding from JSON")
    func testLoginRequestDecoding() throws {
        let jsonString = """
        {
            "username": "testuser",
            "password": "testpass"
        }
        """
        let data = jsonString.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let loginRequest = try decoder.decode(LoginRequest.self, from: data)
        
        #expect(loginRequest.username == "testuser")
        #expect(loginRequest.password == "testpass")
    }
    
    @Test("LoginResponse encoding produces valid JSON")
    func testLoginResponseEncoding() throws {
        let loginResponse = LoginResponse(
            accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9",
            refreshToken: "refresh123"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(loginResponse)
        let jsonString = String(data: data, encoding: .utf8)
        
        #expect(jsonString != nil)
        #expect(jsonString?.contains("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9") == true)
        #expect(jsonString?.contains("refresh123") == true)
    }
    
    @Test("LoginResponse decoding from JSON")
    func testLoginResponseDecoding() throws {
        let jsonString = """
        {
            "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9",
            "refreshToken": "refresh123"
        }
        """
        let data = jsonString.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let loginResponse = try decoder.decode(LoginResponse.self, from: data)
        
        #expect(loginResponse.accessToken == "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9")
        #expect(loginResponse.refreshToken == "refresh123")
    }
    
    @Test("AuthState equality comparison")
    func testAuthStateEquality() {
        #expect(AuthState.idle == AuthState.idle)
        #expect(AuthState.loading == AuthState.loading)
        #expect(AuthState.authenticated == AuthState.authenticated)
        #expect(AuthState.error("test") == AuthState.error("test"))
        #expect(AuthState.error("test1") != AuthState.error("test2"))
    }
}
