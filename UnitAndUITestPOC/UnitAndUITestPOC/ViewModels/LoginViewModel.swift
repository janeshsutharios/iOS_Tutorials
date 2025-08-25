//
//  LoginViewModel.swift
//  UnitAndUITestPOC
//
//  Created by Janesh Suthar on 25/08/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var username: String = "test"
    @Published var password: String = "password"
    @Published var authState: AuthState = .idle
    @Published var isAuthenticated: Bool = false
    @Published var accessToken: String = ""
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }
    
    var isLoading: Bool {
        if case .loading = authState {
            return true
        }
        return false
    }
    
    var errorMessage: String? {
        if case .error(let message) = authState {
            return message
        }
        return nil
    }
    
    func login() async {
        guard !username.isEmpty && !password.isEmpty else {
            authState = .error("Please enter both username and password")
            return
        }
        
        authState = .loading
        
        do {
            let response = try await authService.login(username: username, password: password)
            accessToken = response.accessToken
            authState = .authenticated
            isAuthenticated = true
        } catch let error as NetworkError {
            authState = .error(error.errorDescription ?? "Login failed")
        } catch {
            authState = .error("An unexpected error occurred")
        }
    }
    
    func resetState() {
        authState = .idle
        username = ""
        password = ""
    }
}
