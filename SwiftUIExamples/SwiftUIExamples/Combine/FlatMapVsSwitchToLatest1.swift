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

    private var useSwitchToLatest: Bool
    private var cancellables = Set<AnyCancellable>()

    init(useSwitchToLatest: Bool) {
        self.useSwitchToLatest = useSwitchToLatest

        let searchPublisher = $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .map { [weak self] query -> AnyPublisher<[GitHubUser], Never> in
                guard let self = self else { return Just([]).eraseToAnyPublisher() }
                return self.searchGitHubUsers(query: query)
            }

        let userPublisher: AnyPublisher<[GitHubUser], Never> = useSwitchToLatest
            ? searchPublisher.switchToLatest().eraseToAnyPublisher()
            : searchPublisher.flatMap { $0 }.eraseToAnyPublisher()

        userPublisher
            .sink { [weak self] users in
                self?.users = users
            }
            .store(in: &cancellables)
    }

    private func searchGitHubUsers(query: String) -> AnyPublisher<[GitHubUser], Never> {
        self.error = nil

        guard !query.isEmpty,
              let url = URL(string: "https://api.github.com/search/users?q=\(query)")
        else {
            return Just([]).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .receive(on: RunLoop.main)
            .decode(type: GitHubResponse.self, decoder: JSONDecoder())
            .map { $0.items }
            .catch { [weak self] error -> Just<[GitHubUser]> in
                self?.error = error
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
/** Using async await
 import SwiftUI
 import Foundation

 // MARK: - Models

 struct GitHubUser: Decodable, Identifiable {
     var id: String { login }
     let login: String
     let avatar_url: String
 }

 struct GitHubResponse: Decodable {
     let items: [GitHubUser]
 }

 // MARK: - ViewModel

 @MainActor
 class GitHubSearchViewModel: ObservableObject {
     @Published var searchText = ""
     @Published var users: [GitHubUser] = []
     @Published var error: String?

     private var searchTask: Task<Void, Never>?

     init() {
         observeSearchText()
     }

     private func observeSearchText() {
         // Debounce and observe changes to searchText
         Task {
             for await text in $searchText.debounce(seconds: 0.3).removeDuplicates() {
                 await performSearch(for: text)
             }
         }
     }

     private func performSearch(for query: String) async {
         searchTask?.cancel()
         searchTask = Task {
             guard !query.isEmpty else {
                 self.users = []
                 self.error = nil
                 return
             }

             do {
                 let result = try await fetchGitHubUsers(query: query)
                 self.users = result
                 self.error = nil
             } catch {
                 self.users = []
                 self.error = error.localizedDescription
             }
         }
     }

     private func fetchGitHubUsers(query: String) async throws -> [GitHubUser] {
         guard let url = URL(string: "https://api.github.com/search/users?q=\(query)") else {
             return []
         }

         let (data, _) = try await URLSession.shared.data(from: url)
         let response = try JSONDecoder().decode(GitHubResponse.self, from: data)
         return response.items
     }
 }

 // MARK: - View

 struct GitHubSearchView: View {
     @StateObject private var viewModel = GitHubSearchViewModel()

     var body: some View {
         VStack {
             TextField("Search GitHub users", text: $viewModel.searchText)
                 .textFieldStyle(RoundedBorderTextFieldStyle())
                 .padding()

             if let error = viewModel.error {
                 Text("Error: \(error)")
                     .foregroundColor(.red)
                     .padding()
             }

             if viewModel.users.isEmpty {
                 Text(viewModel.searchText.isEmpty ? "Type something" : "No results")
                     .foregroundColor(.gray)
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

 // MARK: - Async Publisher Helpers (Swift Concurrency alternative to Combine)

 extension Published.Publisher {
     func debounce(seconds: TimeInterval) -> AsyncStream<Value> {
         AsyncStream { continuation in
             var task: Task<Void, Never>?

             let cancellable = self.sink { value in
                 task?.cancel()
                 task = Task {
                     try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                     continuation.yield(value)
                 }
             }

             continuation.onTermination = { _ in
                 task?.cancel()
                 cancellable.cancel()
             }
         }
     }

     func removeDuplicates() -> AsyncStream<Value> where Value: Equatable {
         AsyncStream { continuation in
             var lastValue: Value?
             let cancellable = self.sink { value in
                 guard value != lastValue else { return }
                 lastValue = value
                 continuation.yield(value)
             }

             continuation.onTermination = { _ in
                 cancellable.cancel()
             }
         }
     }
 }

 */
