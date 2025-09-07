//
//  ForgotPasswordView.swift
//  Auth
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI
import Services
import Combine


public struct ForgotPasswordView: View {
    @StateObject private var viewModel = ForgotPasswordViewModel()
    @EnvironmentObject private var router: AuthRouter
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Reset Password")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Enter your email address and we'll send you a reset code.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Button("Send Reset Code") {
                viewModel.sendResetCode()
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
            
            if viewModel.codeSent {
                Text("Reset code sent! Check your email.")
                    .foregroundColor(.green)
                    .font(.caption)
            }
            
            Button("Back to Login") {
                router.navigate(to: .login)
            }
            .font(.caption)
        }
        .padding()
    }
}

// MARK: - Forgot Password ViewModel

@MainActor
public final class ForgotPasswordViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var codeSent: Bool = false
    
    private let authService: AuthServiceProtocol
    
    public init(authService: AuthServiceProtocol = MockAuthService()) {
        self.authService = authService
    }
    
    public func sendResetCode() {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email address"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let success = try await authService.forgotPassword(email: email)
                if success {
                    codeSent = true
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
