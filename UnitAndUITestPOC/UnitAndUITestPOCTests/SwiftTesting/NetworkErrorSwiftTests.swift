//
//  NetworkErrorSwiftTests.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import Testing
@testable import UnitAndUITestPOC

@Suite("Network Error Handling")
struct NetworkErrorSwiftTests {
    
    @Test("NetworkError descriptions are properly formatted")
    func testNetworkErrorDescriptions() {
        #expect(NetworkError.invalidURL.errorDescription == "Invalid URL")
        #expect(NetworkError.noData.errorDescription == "No data received")
        #expect(NetworkError.decodingError.errorDescription == "Failed to decode response")
        #expect(NetworkError.unauthorized.errorDescription == "Unauthorized access")
        #expect(NetworkError.unknown.errorDescription == "Unknown error occurred")
    }
    
    @Test("ServerError includes status code in description")
    func testServerErrorDescription() {
        let error = NetworkError.serverError(404)
        #expect(error.errorDescription == "Server error with code: 404")
    }
    
    @Test("NetworkError includes underlying error in description")
    func testNetworkErrorDescription() {
        let testError = NSError(domain: "TestDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        let error = NetworkError.networkError(testError)
        #expect(error.errorDescription == "Network error: Test error")
    }
    
    @Test("NetworkError equality comparison")
    func testNetworkErrorEquality() {
        #expect(NetworkError.invalidURL == NetworkError.invalidURL)
        #expect(NetworkError.noData == NetworkError.noData)
        #expect(NetworkError.decodingError == NetworkError.decodingError)
        #expect(NetworkError.unauthorized == NetworkError.unauthorized)
        #expect(NetworkError.unknown == NetworkError.unknown)
        #expect(NetworkError.serverError(404) == NetworkError.serverError(404))
        #expect(NetworkError.serverError(404) != NetworkError.serverError(500))
        
        let testError1 = NSError(domain: "Test", code: 1)
        let testError2 = NSError(domain: "Test", code: 1)
        #expect(NetworkError.networkError(testError1) == NetworkError.networkError(testError2))
    }
}
