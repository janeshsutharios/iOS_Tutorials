//
//  LoginView.swift
//  Concurrancy1
//
//  Created by Janesh Suthar on 16/08/25.
//


import SwiftUI

struct LoginView: View {
    @State private var username = "test"
    @State private var password = "password"
    @State private var errorMessage: String?
    @ObservedObject private var auth = AuthService.shared
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
            
            Button("Login") {
                Task {
                    do {
                        try await auth.login(username: username, password: password)
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Login")
    }
}