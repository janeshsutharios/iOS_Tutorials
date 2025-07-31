import SwiftUI

// MARK: - Repo Service Protocol

protocol RepoServiceProtocol: Sendable {
    func fetchRepos() async -> [String]
}

struct MockRepoService: RepoServiceProtocol {
    func fetchRepos() async -> [String] {
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 sec
        return ["MockRepo1", "MockRepo2"]
    }
}

// MARK: - Actor

actor RepoActor {
    private let service: RepoServiceProtocol

    init(service: RepoServiceProtocol) {
        self.service = service
    }

    func loadRepos() async -> [String] {
        await service.fetchRepos()
    }
}

// MARK: - View

struct ProjectsListView: View {
    @State private var repos: [String] = []
    private let repoActor: RepoActor

    init(service: RepoServiceProtocol = MockRepoService()) {
        self.repoActor = RepoActor(service: service)
    }

    var body: some View {
        NavigationView {
            List(repos, id: \.self) { repo in
                Text(repo)
            }
            .navigationTitle("Projects")
            .task {
                await fetchAndUpdate()
            }
        }
    }

    private func fetchAndUpdate() async {
        let result = await repoActor.loadRepos()
        repos = result
    }
}

// MARK: - Preview

struct ProjectsListView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectsListView()
    }
}
