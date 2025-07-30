//
//  LoginView.swift
//  SwiftUIExamples
//
//  Created by JANESH SUTHAR on 09/07/25.
//

import SwiftUI
import Combine

// MARK: - Model
struct User: Sendable {
    let username: String
}

enum LoginError: Error, LocalizedError, Sendable {
    case invalidCredentials
    case networkError

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid username or password."
        case .networkError:
            return "Network error. Please try again."
        }
    }
}

// MARK: - Login Service with Combine
@MainActor
final class LoginService: Sendable {
    // Subject that never completes, just emits success or failure results
    let loginStatus = PassthroughSubject<Result<User, LoginError>, Never>()

    nonisolated func login(username: String, password: String) {
        Task { @MainActor in
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            
            if username == "admin" && password == "1234" {
                loginStatus.send(.success(User(username: username)))
            } else {
                loginStatus.send(.failure(.invalidCredentials))
            }
        }
    }
}

// MARK: - ViewModel
@MainActor
final class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let loginService = LoginService()

    init() {
        loginService.loginStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.isLoading = false
                switch result {
                case .success(let user):
                    self?.isLoggedIn = true
                    self?.errorMessage = nil
                    print("🎉 Logged in as \(user.username)")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
            .store(in: &cancellables)
    }

    func login() {
        errorMessage = nil
        isLoading = true
        loginService.login(username: username, password: password)
    }
}

// MARK: - View
struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Username", text: $viewModel.username)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)

                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top, 4)
                }

                if viewModel.isLoading {
                    ProgressView("Logging in...")
                } else {
                    Button("Login") {
                        viewModel.login()
                    }
                    .padding(.top)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Login")
            .alert("Success", isPresented: $viewModel.isLoggedIn) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Logged in successfully")
            }
        }
    }
}

// MARK: - Preview
#Preview {
    LoginView()
}
/// - Note: Combine Login Flow Update
///
/// This login service originally used:
/// ```swift
/// let loginStatus = PassthroughSubject<User, LoginError>()
///
/// // On failure:
/// self.loginStatus.send(completion: .failure(.invalidCredentials)) // ❌ Kills the subject
/// ```
///
/// This caused the subject to **complete on failure**, making it unusable for subsequent login attempts.
///
/// ---
///
/// ✅ **Updated Approach**
///
/// The subject now emits a `Result<User, LoginError>` instead of completing:
///
/// ```swift
/// let loginStatus = PassthroughSubject<Result<User, LoginError>, Never>()
///
/// // On failure:
/// self.loginStatus.send(.failure(.invalidCredentials)) // ✅ Subject stays alive
///
/// // On success:
/// self.loginStatus.send(.success(User(username: username)))
/// ```
///
/// - Benefits:
///   - No premature termination of the Combine pipeline
///   - Works on multiple login attempts
///   - Error and success are handled through a single unified value (`Result`)
///
/// - Usage Example:
/// ```swift
/// loginService.loginStatus
///     .sink { result in
///         switch result {
///         case .success(let user): print("✅ \(user.username)")
///         case .failure(let error): print("❌ \(error)")
///         }
///     }
///     .store(in: &cancellables)
/// ```
