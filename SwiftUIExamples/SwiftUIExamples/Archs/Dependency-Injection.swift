import SwiftUI

// MARK: - Protocol

protocol RepoServiceProtocol: Sendable {
    //    func fetchRepos(completion: @escaping ([String]) -> Void)
    // clouser replaced with async
    func fetchRepos() async -> [String]
}

// MARK: - Real Service

final class RepoService: RepoServiceProtocol {
    func fetchRepos() async -> [String] {
        try? await Task.sleep(nanoseconds: 1_000_000_000) // Simulate 1 second delay
        return ["Swift", "Combine", "UIKit", "CoreData"]
    }
}

// MARK: - Mock Service (for previews or unit tests)

final class MockRepoService: RepoServiceProtocol {
    func fetchRepos() async -> [String] {
        return ["MockRepo1", "MockRepo2"]
    }
}

// MARK: - ViewModel

@MainActor
final class RepoViewModel: ObservableObject {
    @Published var repos: [String] = []
    private let service: any RepoServiceProtocol
    
    init(service: any RepoServiceProtocol) {
        self.service = service
    }
    
    // fetchRepos() is nonisolated — it won’t run on MainActor.
    nonisolated func loadRepos() async {
        // This runs on background thread
        let repos = await service.fetchRepos()
        
        // Switch to main actor for UI update
        await setRepos(repos)
    }
    
    private func setRepos(_ repos: [String]) {
        self.repos = repos
    }
}

// MARK: - View

struct ProjectsListView: View {
    @StateObject var viewModel: RepoViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.repos, id: \.self) { repo in
                Text(repo)
            }
            .navigationTitle("Projects")
            .task {
                await viewModel.loadRepos()
            }
        }
    }
}

struct ProjectsListView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectsListView(viewModel: .init(service: MockRepoService()))
    }
}
