//
//  NetworkErrorTests.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import XCTest
@testable import UnitAndUITestPOC

final class NetworkErrorTests: XCTestCase {
    
    func testNetworkErrorDescriptions() {
        // Given & When & Then
        XCTAssertEqual(NetworkError.invalidURL.errorDescription, "Invalid URL")
        XCTAssertEqual(NetworkError.noData.errorDescription, "No data received")
        XCTAssertEqual(NetworkError.decodingError.errorDescription, "Failed to decode response")
        XCTAssertEqual(NetworkError.unauthorized.errorDescription, "Unauthorized access")
        XCTAssertEqual(NetworkError.unknown.errorDescription, "Unknown error occurred")
    }
    
    func testServerErrorDescription() {
        // Given
        let error = NetworkError.serverError(404)
        
        // When & Then
        XCTAssertEqual(error.errorDescription, "Server error with code: 404")
    }
    
    func testNetworkErrorDescription() {
        // Given
        let testError = NSError(domain: "TestDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        let error = NetworkError.networkError(testError)
        
        // When & Then
        XCTAssertEqual(error.errorDescription, "Network error: Test error")
    }
    
    func testNetworkErrorEquality() {
        // Given & When & Then
        XCTAssertEqual(NetworkError.invalidURL, NetworkError.invalidURL)
        XCTAssertEqual(NetworkError.noData, NetworkError.noData)
        XCTAssertEqual(NetworkError.decodingError, NetworkError.decodingError)
        XCTAssertEqual(NetworkError.unauthorized, NetworkError.unauthorized)
        XCTAssertEqual(NetworkError.unknown, NetworkError.unknown)
        XCTAssertEqual(NetworkError.serverError(404), NetworkError.serverError(404))
        XCTAssertNotEqual(NetworkError.serverError(404), NetworkError.serverError(500))
        
        let testError1 = NSError(domain: "Test", code: 1)
        let testError2 = NSError(domain: "Test", code: 1)
        XCTAssertEqual(NetworkError.networkError(testError1), NetworkError.networkError(testError2))
    }
}
