//
//  LoginView.swift
//  Auth
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI
import Services

public struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject private var router: AuthRouter
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Welcome Back")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Button("Login") {
                viewModel.login()
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
            
            if viewModel.isLoading {
                ProgressView()
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            HStack {
                Button("Sign Up") {
                    router.navigate(to: .signup)
                }
                
                Spacer()
                
                Button("Forgot Password?") {
                    router.navigate(to: .forgotPassword)
                }
            }
            .font(.caption)
        }
        .padding()
        .onReceive(viewModel.$isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                // Handle successful authentication
                // This would typically be handled by the main app coordinator
            }
        }
    }
}

// MARK: - Login ViewModel
@MainActor
public final class LoginViewModel: ObservableObject {
    @Published var email: String = "test@example.com"
    @Published var password: String = "password123"
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    
    private let authService: AuthServiceProtocol
    
    public init(authService: AuthServiceProtocol = MockAuthService()) {
        self.authService = authService
    }
    
    public func login() {
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let success = try await authService.login(email: email, password: password)
                if success {
                    isAuthenticated = true
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
