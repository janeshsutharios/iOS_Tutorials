import SwiftUI
import Combine
import Foundation

// MARK: - ViewModel

class GitHubSearchViewModel2: ObservableObject {
    @Published var searchText = ""
    @Published var users: [GitHubUser] = []
    @Published var useSwitchToLatest: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private var searchCancellable: AnyCancellable?

    init() {
        setupSearchPipeline()
    }

    private func setupSearchPipeline() {
        Publishers.CombineLatest($searchText, $useSwitchToLatest)
            //.debounce(for: .milliseconds(300), scheduler: RunLoop.main)
           // .removeDuplicates { $0.0 == $1.0 } // only if text changes
            .sink { [weak self] searchText, useSwitch in
                self?.startSearch(for: searchText, useSwitchToLatest: useSwitch)
            }
            .store(in: &cancellables)
    }

    private func startSearch(for text: String, useSwitchToLatest: Bool) {
        searchCancellable?.cancel()

        let searchPublisher = Just(text)
            .map { [weak self] query in
                self?.searchGitHubUsers(query: query) ?? Just([]).eraseToAnyPublisher()
            }

        let publisher = useSwitchToLatest
            ? searchPublisher.switchToLatest().eraseToAnyPublisher()
            : searchPublisher.flatMap { $0 }.eraseToAnyPublisher()
        

        searchCancellable = publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.users = $0 }
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

// MARK: - View

struct GitHubSearchView2: View {
    @StateObject var viewModel = GitHubSearchViewModel2()

    var body: some View {
        VStack {
            Toggle(isOn: $viewModel.useSwitchToLatest) {
                Text("Use switchToLatest")
            }
            .padding()

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
    GitHubSearchView2()
}
