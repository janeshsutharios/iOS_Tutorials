//
//  FlatMapSwitchToLatest.swift
//  SwiftUIExamples
//
//  Created by JANESH SUTHAR on 14/07/25.
//

import SwiftUI
import Combine
import Foundation

struct GitHubUser: Decodable, Identifiable {
    var id: String { login }
    let login: String
    let avatar_url: String
}

struct GitHubResponse: Decodable {
    let items: [GitHubUser]
}

class GitHubSearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var users: [GitHubUser] = []
    @Published var error: Error? = nil
    var useSwitchToLatest: Bool
    private var cancellables = Set<AnyCancellable>()
    
    init(useSwitchToLatest: Bool) {
        self.useSwitchToLatest = useSwitchToLatest
        
        let searchPublisher = $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .map { query in
                self.searchGitHubUsers(query: query)
            }
        
        let userPublisher: AnyPublisher<[GitHubUser], Never> = useSwitchToLatest
            ? searchPublisher.switchToLatest().eraseToAnyPublisher()
            : searchPublisher.flatMap { $0 }.eraseToAnyPublisher()
        
        userPublisher
            .receive(on: DispatchQueue.main)
            .sink { self.users = $0 }
            .store(in: &cancellables)
    }

    private func searchGitHubUsers(query: String) -> AnyPublisher<[GitHubUser], Never> {
        error = nil
        guard !query.isEmpty,
              let url = URL(string: "https://api.github.com/search/users?q=\(query)")
        else {
            return Just([]).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: GitHubResponse.self, decoder: JSONDecoder())
            .map { $0.items }
            // Or replaceError(with: [])
            .catch { [weak self] error -> Just<[GitHubUser]> in
                DispatchQueue.main.async {
                    self?.error = error
                }
                return Just([])
            }
            .eraseToAnyPublisher()
    }
}

struct GitHubSearchView: View {
    @StateObject var viewModel = GitHubSearchViewModel(useSwitchToLatest: false)
    
    var body: some View {
        VStack {
            TextField("Search GitHub users", text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            if viewModel.users.isEmpty {
                Text(viewModel.searchText.isEmpty ? "Type something" : "No results")
            }
            
            List(viewModel.users) { user in
                HStack {
                    AsyncImage(url: URL(string: user.avatar_url)) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())

                    Text(user.login)
                        .font(.headline)
                }
            }
        }
        .navigationTitle("GitHub Search")
    }
}
