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

        if useSwitchToLatest {
            searchPublisher
                .switchToLatest()
                .receive(on: DispatchQueue.main)
                .sink { self.users = $0 }
                .store(in: &cancellables)
        } else {
            searchPublisher
                .flatMap { $0 }
                .receive(on: DispatchQueue.main)
                .sink { self.users = $0 }
                .store(in: &cancellables)
        }
    }

    private func searchGitHubUsers(query: String) -> AnyPublisher<[GitHubUser], Never> {
        guard !query.isEmpty,
              let url = URL(string: "https://api.github.com/search/users?q=\(query)")
        else {
            return Just([]).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: GitHubResponse.self, decoder: JSONDecoder())
            .map { $0.items }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
}

struct GitHubSearchView: View {
    @StateObject var viewModel = GitHubSearchViewModel(useSwitchToLatest: true)

    var body: some View {
        VStack {
            TextField("Search GitHub users", text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

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

#Preview {
    GitHubSearchView()
}
