//
//  LoginViewModel.swift
//  FoodApp
//
//  Created by Janesh Suthar on 05/08/25.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var email = "test@gmail.com"
    @Published var password = "123"
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var isAuthenticated = false
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }
    
    func login() {
        isLoading = true
        errorMessage = ""
        
        authService.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    self?.isAuthenticated = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
