//
//  HandleEventsPublisher.swift
//  SwiftUIExamples
//
//  Created by JANESH SUTHAR on 14/07/25.
//

import SwiftUI
import Combine

class GitHubSearchViewModel3: ObservableObject {
    @Published var searchText = ""
    @Published private(set) var users: [GitHubUser] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    init() {
        $searchText
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .removeDuplicates()
            .map { [weak self] text -> AnyPublisher<[GitHubUser], Never> in
                guard let self = self else { return Just([]).eraseToAnyPublisher() }
                return self.fetchUsers(query: text)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                self?.isLoading = false
                self?.users = users
            }
            .store(in: &cancellables)
    }

    private func fetchUsers(query: String) -> AnyPublisher<[GitHubUser], Never> {
        guard !query.isEmpty,
              let url = URL(string: "https://api.github.com/search/users?q=\(query)")
        else {
            return Just([]).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .handleEvents(
                receiveSubscription: { [weak self] _ in
                    print("🔄 Starting network call for: \(query)")
                    self?.isLoading = true
                    self?.errorMessage = nil
                },
                receiveOutput: { _ in
                    print("✅ Received data for: \(query)")
                },
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("✅ Finished search for: \(query)")
                    case .failure(let error):
                        print("❌ Error: \(error.localizedDescription)")
                    }
                },
                receiveCancel: {
                    print("❎ Search cancelled for: \(query)")
                }
            )
            .map(\.data)
            .decode(type: GitHubResponse.self, decoder: JSONDecoder())
            .map { $0.items }
            .catch { [weak self] error -> Just<[GitHubUser]> in
                self?.errorMessage = "Failed to load users: \(error.localizedDescription)"
                return Just([])
            }
            .eraseToAnyPublisher()
    }
}

struct GitHubSearchView3: View {
    @StateObject private var viewModel = GitHubSearchViewModel3()

    var body: some View {
        VStack {
            TextField("Search GitHub Users", text: $viewModel.searchText)
                .textFieldStyle(.roundedBorder)
                .padding()

            if viewModel.isLoading {
                ProgressView("Loading...")
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
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

#Preview {
    GitHubSearchView3()
}
