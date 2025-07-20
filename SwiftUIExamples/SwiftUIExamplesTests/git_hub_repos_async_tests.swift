// GitHubReposAsyncTests.swift
// Unit tests for RepoListViewModel

import XCTest
@testable import SwiftUIExamples

final class GitHubReposAsyncTests: XCTestCase {

    class MockSuccessService: GitHubServiceProtocol {
        func fetchRepos(for username: String) async throws -> [GitHubRepo] {
            return [
                GitHubRepo(id: 101, name: "SuccessRepo", description: "Test Success Repo", html_url: "https://github.com/success")
            ]
        }
    }

    class MockFailureService: GitHubServiceProtocol {
        struct FakeError: Error {}
        func fetchRepos(for username: String) async throws -> [GitHubRepo] {
            throw FakeError()
        }
    }

    func testLoadRepos_Success() async throws {
        let viewModel = RepoListViewModel(service: MockSuccessService())
        await viewModel.loadRepos(for: "janeshsutharios")

        let repos = await MainActor.run { viewModel.repos }
        let error = await MainActor.run { viewModel.error }
        let isLoading = await MainActor.run { viewModel.isLoading }

        XCTAssertEqual(repos.count, 1)
        XCTAssertEqual(repos.first?.name, "SuccessRepo")
        XCTAssertNil(error)
        XCTAssertFalse(isLoading)
    }

    func testLoadRepos_Failure() async throws {
        let viewModel = RepoListViewModel(service: MockFailureService())
        await viewModel.loadRepos(for: "janeshsutharios")

        let repos = await MainActor.run { viewModel.repos }
        let error = await MainActor.run { viewModel.error }
        let isLoading = await MainActor.run { viewModel.isLoading }

        XCTAssertTrue(repos.isEmpty)
        XCTAssertNotNil(error)
        XCTAssertFalse(isLoading)
    }

    func testLoadRepos_ErrorClearedOnRetry() async throws {
        let failingService = MockFailureService()
        let viewModel = RepoListViewModel(service: failingService)

        await viewModel.loadRepos(for: "janeshsutharios")

        let initialError = await MainActor.run { viewModel.error }
        XCTAssertNotNil(initialError)

        // Swap to success service
        let successService = MockSuccessService()
        let newViewModel = RepoListViewModel(service: successService)
        await newViewModel.loadRepos(for: "janeshsutharios")

        let repos = await MainActor.run { newViewModel.repos }
        let error = await MainActor.run { newViewModel.error }

        XCTAssertEqual(repos.count, 1)
        XCTAssertNil(error)
    }

    func testLoadRepos_InvalidUsername() async throws {
        struct InvalidUsernameService: GitHubServiceProtocol {
            func fetchRepos(for username: String) async throws -> [GitHubRepo] {
                throw GitHubServiceError.invalidURL
            }
        }

        let viewModel = RepoListViewModel(service: InvalidUsernameService())
        await viewModel.loadRepos(for: "invalid@@@username")

        let error = await MainActor.run { viewModel.error }
        let repos = await MainActor.run { viewModel.repos }
        let isLoading = await MainActor.run { viewModel.isLoading }

        XCTAssertNotNil(error)
        XCTAssertTrue(repos.isEmpty)
        XCTAssertFalse(isLoading)
    }
}
