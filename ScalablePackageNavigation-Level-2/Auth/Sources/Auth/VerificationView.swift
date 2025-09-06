//
//  VerificationView.swift
//  Auth
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI
import Services
import Combine

public struct VerificationView: View {
    @StateObject private var viewModel = VerificationViewModel()
    @EnvironmentObject private var router: AuthRouter
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Verify Code")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Enter the verification code sent to your email.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                TextField("Verification Code", text: $viewModel.code)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
            }
            
            Button("Verify") {
                viewModel.verifyCode()
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
            
            if viewModel.isVerified {
                Text("Code verified successfully!")
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

// MARK: - Verification ViewModel
@MainActor
public final class VerificationViewModel: ObservableObject {
    @Published var code: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isVerified: Bool = false
    
    private let authService: AuthServiceProtocol
    
    public init(authService: AuthServiceProtocol = MockAuthService()) {
        self.authService = authService
    }
    
    public func verifyCode() {
        guard !code.isEmpty else {
            errorMessage = "Please enter the verification code"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let success = try await authService.verifyCode(code: code)
                if success {
                    isVerified = true
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
