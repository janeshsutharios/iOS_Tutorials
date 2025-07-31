//
//  DependencyInjectionTests.swift
//  SwiftUIExamplesTests
//
//  Created by Janesh Suthar on 31/07/25.
//

import XCTest

// MARK: - Mock Service for Testing
@testable import SwiftUIExamples
struct TestRepoService: RepoServiceProtocol {
    let reposToReturn: [String]

    func fetchRepos() async -> [String] {
        return reposToReturn
    }
}

// MARK: - Unit Tests

final class RepoActorTests: XCTestCase {
    
    func test_loadRepos_returnsExpectedData() async {
        // Given
        let expectedRepos = ["TestRepo1", "TestRepo2"]
        let service = TestRepoService(reposToReturn: expectedRepos)
        let actor = RepoActor(service: service)
        
        // When
        let result = await actor.loadRepos()
        
        // Then
        XCTAssertEqual(result, expectedRepos)
    }
    
    func test_loadRepos_returnsEmptyList() async {
        // Given
        let service = TestRepoService(reposToReturn: [])
        let actor = RepoActor(service: service)

        // When
        let result = await actor.loadRepos()

        // Then
        XCTAssertTrue(result.isEmpty)
    }
}
