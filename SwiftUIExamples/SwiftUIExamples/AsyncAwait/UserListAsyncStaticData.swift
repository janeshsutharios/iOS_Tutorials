import SwiftUI

// MARK: - Model

struct UserModel: Identifiable, Decodable, Equatable {
    let id: Int
    let name: String
}

// MARK: - Protocol for User Service

protocol UserServiceProtocol: Sendable {
    func fetchUsers() async throws -> [UserModel]
}

// MARK: - Real API Implementation

struct UserService: UserServiceProtocol {
    func fetchUsers() async throws -> [UserModel] {
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([UserModel].self, from: data)
    }
}

// MARK: - ViewModel State (safe snapshot to share with View)

struct UserListViewModelState: Equatable {
    var isLoading = false
    var users: [UserModel] = []
    var error: String? = nil
}

// MARK: - ViewModel as Actor (concurrency-safe)

actor UserListViewModel {
    private let userService: UserServiceProtocol
    private var state = UserListViewModelState()

    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
    }

    func loadUsers() async -> UserListViewModelState {
        state.isLoading = true
        state.users = []
        state.error = nil

        do {
            let result = try await userService.fetchUsers()
            state.users = result
        } catch {
            state.error = error.localizedDescription
        }

        state.isLoading = false
        return state
    }
}

// MARK: - SwiftUI View

struct UserListView: View {
    private let viewModel = UserListViewModel()
    @State private var state = UserListViewModelState()

    var body: some View {
        NavigationView {
            Group {
                if state.isLoading {
                    ProgressView("Loading...")
                } else if let error = state.error {
                    Text("❌ \(error)").foregroundColor(.red)
                } else {
                    List(state.users) { user in
                        Text(user.name)
                    }
                }
            }
            .navigationTitle("Users")
            .task {
                let newState = await viewModel.loadUsers()
                await MainActor.run {
                    self.state = newState
                }
            }
        }
    }
}

// MARK: - Mock Service for Preview

struct MockUserService: UserServiceProtocol {
    func fetchUsers() async throws -> [UserModel] {
        try? await Task.sleep(nanoseconds: 300_000_000) // simulate delay
        return [
            UserModel(id: 1, name: "Mock Alice"),
            UserModel(id: 2, name: "Mock Bob")
        ]
    }
}

// MARK: - Preview

struct UserListView_Previews: PreviewProvider {
    static var previews: some View {
        UserListView()
    }
}
