//
// GitHubReposAsyncApp.swift
// SwiftUI App to fetch public GitHub repos using async/await
// Swift 6 Compatible
//

import SwiftUI

// MARK: - Model

struct GitHubRepo: Identifiable, Decodable, Sendable {
    let id: Int
    let name: String
    let description: String?
    let html_url: String
}

struct GitHubUnknownError: LocalizedError {
    let message: String

    var errorDescription: String? {
        return message
    }
}

// MARK: - Protocol

protocol GitHubServiceProtocol: Sendable {
    func fetchRepos(for username: String) async throws -> [GitHubRepo]
}

// MARK: - Real Service Implementation

enum GitHubServiceError: Error, LocalizedError, Equatable, Sendable {
    
    static func == (lhs: GitHubServiceError, rhs: GitHubServiceError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.networkError(let lhsError), .networkError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.decodingError(let lhsError), .decodingError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
    
    case invalidURL
    case networkError(Error)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The GitHub API URL is invalid. Please check the username."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription). Please check your internet connection."
        case .decodingError(let error):
            return "Failed to process data from GitHub: \(error.localizedDescription)"
        }
    }
}

final class GitHubService: GitHubServiceProtocol {
    func fetchRepos(for username: String) async throws -> [GitHubRepo] {
        guard let url = URL(string: "https://api.github.com/users/\(username)/repos") else {
            throw GitHubServiceError.invalidURL
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            // ✅ Check for valid HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw GitHubServiceError.networkError(URLError(.badServerResponse))
            }

            // ✅ Ensure status code is 200
            guard (200...299).contains(httpResponse.statusCode) else {
                throw GitHubServiceError.networkError(
                    URLError(.init(rawValue: httpResponse.statusCode))
                )
            }

            return try JSONDecoder().decode([GitHubRepo].self, from: data)

        } catch let decodingError as DecodingError {
            throw GitHubServiceError.decodingError(decodingError)
        } catch {
            throw GitHubServiceError.networkError(error)
        }
    }
}

// MARK: - ViewModel Protocol

@MainActor
protocol RepoListViewModelProtocol: ObservableObject {
    var repos: [GitHubRepo] { get }
    var isLoading: Bool { get }
    var error: String? { get }
    func loadRepos(for username: String) async
}

// MARK: - ViewModel

@MainActor
final class RepoListViewModel: RepoListViewModelProtocol {
    @Published private(set) var repos: [GitHubRepo] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: String? = nil

    private let service: GitHubServiceProtocol

    init(service: GitHubServiceProtocol = GitHubService()) {
        self.service = service
    }

    func loadRepos(for username: String) async {
        isLoading = true
        error = nil // Clear previous errors
        
        let result = await fetchRepos(username)
        
        switch result {
        case .success(let fetchedRepos):
            repos = fetchedRepos
        case .failure(let errorMessage):
            error = errorMessage.localizedDescription
            repos = [] // Clear repos on error
        }
        
        isLoading = false
    }
    
    private nonisolated func fetchRepos(_ username: String) async -> Result<[GitHubRepo], Error> {
        do {
            let fetchedRepos = try await service.fetchRepos(for: username)
            return .success(fetchedRepos)
        } catch {
            if let githubError = error as? GitHubServiceError {
                return .failure(githubError)
            } else {
                let unknown = GitHubUnknownError(message: "An unexpected error occurred: \(error.localizedDescription)")
                return .failure(unknown)
            }
        }
    }

}

// MARK: - View

struct RepoListView<VM: RepoListViewModelProtocol>: View {
    @StateObject private var viewModel: VM
    let username: String

    // Initializer to allow injecting a specific ViewModel (e.g., for previews/testing)
    init(username: String, viewModel: @autoclosure @escaping () -> VM) {
        self.username = username
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let error = viewModel.error {
                Text("❌ \(error)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            } else if viewModel.repos.isEmpty {
                ContentUnavailableView("No Repos Found", systemImage: "xmark.octagon.fill")
            } else {
                List(viewModel.repos) { repo in
                    Link(destination: URL(string: repo.html_url)!) {
                        VStack(alignment: .leading) {
                            Text(repo.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            if let desc = repo.description, !desc.isEmpty {
                                Text(desc)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("\(username)'s Repos")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadRepos(for: username)
        }
    }
}

// MARK: - Preview

struct RepoListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RepoListView(username: "janeshsutharios", viewModel: RepoListViewModel(service: MockGitHubService()))
        }
    }
}

// MARK: - Mock Service for Preview/Test

final class MockGitHubService: GitHubServiceProtocol {
    func fetchRepos(for username: String) async throws -> [GitHubRepo] {
        // Simulate a small delay for a more realistic preview
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        if username == "errorUser" {
            throw GitHubServiceError.networkError(URLError(.notConnectedToInternet))
        }
        return [
            GitHubRepo(id: 1, name: "TestRepo1", description: "This is a sample repository for testing purposes.", html_url: "https://github.com/test1"),
            GitHubRepo(id: 2, name: "AnotherRepo", description: nil, html_url: "https://github.com/test2"),
            GitHubRepo(id: 3, name: "AwesomeProject", description: "A project that does awesome things with SwiftUI and async/await.", html_url: "https://github.com/test3")
        ]
    }
}
