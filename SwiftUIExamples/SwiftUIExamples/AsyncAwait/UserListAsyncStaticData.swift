//
//  UserListAsyncApp.swift
//  SwiftUIExamples
//
//  Created by JANESH SUTHAR on 20/07/25.
//

import SwiftUI

// MARK: - Model

struct UserModel: Identifiable, Decodable {
    let id: Int
    let name: String
}

// MARK: - Protocol for User Service

@MainActor
protocol UserServiceProtocol {
    func fetchUsers() async throws -> [UserModel]
}

// MARK: - Real API Implementation

class UserService: UserServiceProtocol {
    func fetchUsers() async throws -> [UserModel] {
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([UserModel].self, from: data)
    }
}

// MARK: - ViewModel Protocol
@MainActor
protocol UserListViewModelProtocol: ObservableObject {
    var users: [UserModel] { get }
    var isLoading: Bool { get }
    var error: String? { get }
    func loadUsers() async
}

// MARK: - ViewModel

class UserListViewModel: UserListViewModelProtocol {
    @Published private(set) var users: [UserModel] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: String? = nil

    private let userService: UserServiceProtocol

    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
    }

    func loadUsers() async {
        isLoading = true
        error = nil
        do {
            users = try await userService.fetchUsers()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - SwiftUI View
@MainActor
struct UserListView<VM: UserListViewModelProtocol>: View {
    @StateObject private var viewModel: VM

    init(viewModel: @autoclosure @escaping () -> VM) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let error = viewModel.error {
                    Text("❌ \(error)")
                        .foregroundColor(.red)
                } else {
                    List(viewModel.users) { user in
                        Text(user.name)
                    }
                }
            }
            .navigationTitle("Users")
        }
        .task {
            await viewModel.loadUsers()
        }
    }
}

// MARK: - Mock for Preview & Tests

class MockUserService: UserServiceProtocol {
    func fetchUsers() async throws -> [UserModel] {
        return [
            UserModel(id: 1, name: "Mock Alice"),
            UserModel(id: 2, name: "Mock Bob")
        ]
    }
}

// MARK: - Preview

struct UserListView_Previews: PreviewProvider {
    static var previews: some View {
        UserListView(viewModel: UserListViewModel(userService: MockUserService()))
    }
}
