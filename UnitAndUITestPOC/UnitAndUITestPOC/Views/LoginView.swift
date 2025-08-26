//
//  LoginView.swift
//  UnitAndUITestPOC
//
//  Created by Janesh Suthar on 25/08/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: LoginViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var isPasswordVisible = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dynamic background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(colorScheme == .dark ? 0.25 : 0.6),
                        Color.purple.opacity(colorScheme == .dark ? 0.25 : 0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Logo and title
                        VStack(spacing: 20) {
                            Image(systemName: "fork.knife.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                            
                            Text("Food App")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Sign in to explore delicious food")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.85))
                        }
                        .padding(.top, 60)
                        
                        // Login form
                        VStack(spacing: 20) {
                            // Username field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Username")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                TextField("Enter username", text: $viewModel.username)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            
                            // Password field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                HStack {
                                    if isPasswordVisible {
                                        TextField("Enter password", text: $viewModel.password)
                                            .textFieldStyle(CustomTextFieldStyle())
                                    } else {
                                        SecureField("Enter password", text: $viewModel.password)
                                            .textFieldStyle(CustomTextFieldStyle())
                                    }
                                    
                                    Button(action: {
                                        isPasswordVisible.toggle()
                                    }) {
                                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.trailing, 12)
                                }
                            }
                            
                            // Error message
                            if let errorMessage = viewModel.errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(.horizontal)
                            }
                            
                            // Login button
                            Button(action: {
                                Task { await viewModel.login() }
                            }) {
                                HStack {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Text("Sign In")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.accentColor)   // ✅ Uses app's accent color automatically
                                .foregroundColor(.white)         // ✅ Always readable
                                .cornerRadius(25)
                                .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 2)
                            }
                            .disabled(viewModel.isLoading)
                            
                            // Demo credentials
                            VStack(spacing: 8) {
                                Text("Demo Credentials")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text("Username: test | Password: password")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.top, 20)
                        }
                        .padding(.horizontal, 30)
                        
                        Spacer()
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemBackground)) // ✅ Adapts automatically
            .cornerRadius(12)
            .shadow(color: colorScheme == .dark ? .white.opacity(0.05) : .black.opacity(0.1), radius: 3, x: 0, y: 1)
            .foregroundColor(.primary) // ✅ Text color adapts automatically
    }
}

#Preview {
    LoginView()
        .environmentObject(LoginViewModel())
}
