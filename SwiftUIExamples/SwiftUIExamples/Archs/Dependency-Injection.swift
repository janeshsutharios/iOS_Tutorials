//
// RepoListDIApp.swift
// Complete iOS App using MVVM with Dependency Injection
//

import SwiftUI

// MARK: - View

struct ProjectsListView: View {
    @StateObject var viewModel: RepoViewModel

    var body: some View {
        NavigationView {
            List(viewModel.repos, id: \.self) { repo in
                Text(repo)
            }
            .navigationTitle("Projects")
            .onAppear {
                viewModel.loadRepos()
            }
        }
    }
}


// MARK: - ViewModel

class RepoViewModel: ObservableObject {
    @Published var repos: [String] = []
    private let service: RepoServiceProtocol

    init(service: RepoServiceProtocol) {
        self.service = service
    }

    func loadRepos() {
        service.fetchRepos { [weak self] result in
            DispatchQueue.main.async {
                self?.repos = result
            }
        }
    }
}


// MARK: - Protocol

protocol RepoServiceProtocol {
    func fetchRepos(completion: @escaping ([String]) -> Void)
}


// MARK: - Real Service

class RepoService: RepoServiceProtocol {
    func fetchRepos(completion: @escaping ([String]) -> Void) {
        // Simulate API delay
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            completion(["Swift", "Combine", "UIKit", "CoreData"])
        }
    }
}


// MARK: - Mock Service (for unit tests or previews)

class MockRepoService: RepoServiceProtocol {
    func fetchRepos(completion: @escaping ([String]) -> Void) {
        completion(["MockRepo1", "MockRepo2"])
    }
}
