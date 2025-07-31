import SwiftUI

// MARK: - Model

struct Repo: Identifiable, Decodable, Hashable {
    let id: Int
    let name: String
    let description: String?
    let html_url: String
}

// MARK: - Service Protocol

protocol RepoDirServiceProtocol: Sendable {
    func fetchRepos(for username: String) async throws -> [Repo]
}

// MARK: - Concrete Service

struct GitHubService: RepoDirServiceProtocol {
    func fetchRepos(for username: String) async throws -> [Repo] {
        let url = URL(string: "https://api.github.com/users/\(username)/repos")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Repo].self, from: data)
    }
}

// MARK: - ViewModel State Snapshot (safe to share with SwiftUI View)

struct RepoListViewModelState: Equatable {
    var isLoading = false
    var error: String? = nil
    var repos: [Repo] = []
}

// MARK: - ViewModel Actor (runs off main thread by default)

actor RepoListViewModel {
    private let service: RepoDirServiceProtocol
    private var state = RepoListViewModelState()

    init(service: RepoDirServiceProtocol = GitHubService()) {
        self.service = service
    }

    func load(for username: String) async -> RepoListViewModelState {
        state.isLoading = true
        state.error = nil
        state.repos = []

        do {
            let repos = try await service.fetchRepos(for: username)
            state.repos = repos
        } catch {
            state.error = error.localizedDescription
        }

        state.isLoading = false
        return state
    }
}

// MARK: - SwiftUI View

struct RepoListView: View {
    let username: String
    private let viewModel = RepoListViewModel()

    @State private var state = RepoListViewModelState()

    var body: some View {
        NavigationView {
            content
                .navigationTitle("\(username)'s Repos")
                .task {
                    await loadRepos()
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if state.isLoading {
            ProgressView("Loading…")
        } else if let error = state.error {
            Text("❌ \(error)").foregroundColor(.red)
        } else if state.repos.isEmpty {
            ContentUnavailableView("No Repositories", systemImage: "folder")
        } else {
            List(state.repos) { repo in
                VStack(alignment: .leading) {
                    Text(repo.name).bold()
                    if let description = repo.description {
                        Text(description).font(.subheadline).foregroundColor(.gray)
                    }
                }
            }
        }
    }

    private func loadRepos() async {
        let snapshot = await viewModel.load(for: username)
        await MainActor.run {
            self.state = snapshot
        }
    }
}

// MARK: - Preview

struct RepoListView_Previews: PreviewProvider {
    static var previews: some View {
        RepoListView(username: "apple")
    }
}
