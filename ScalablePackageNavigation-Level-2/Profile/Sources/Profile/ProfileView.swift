//
//  ProfileView.swift
//  Dashboard
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI
import Services
import Combine


public struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject private var router: ProfileRouter
    @State var showAlert = false
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading profile...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let profile = viewModel.profile {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Profile Header
                            VStack(spacing: 16) {
                                Circle()
                                    .fill(Color.blue.opacity(0.3))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Text(String(profile.name.prefix(1)).uppercased())
                                            .font(.largeTitle)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                    )
                                
                                VStack(spacing: 4) {
                                    Text(profile.name)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Text(profile.email)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            
                            // Profile Actions
                            VStack(spacing: 12) {
                                Button("Edit Profile") {
                                    showAlert = true
                                }
                                .alert("Edit Profile can be done here!", isPresented: $showAlert) {
                                    Button("OK", role: .cancel) { }
                                } message: { }

                                .buttonStyle(.borderedProminent)
                                .frame(maxWidth: .infinity)
                                
                                Button("Settings") {
                                    router.navigate(to: .settings)
                                }
                                .buttonStyle(.bordered)
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal)
                        }
                    }
                } else if let error = viewModel.errorMessage {
                    VStack {
                        Text("Error loading profile")
                            .font(.headline)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                        Button("Retry") {
                            viewModel.loadProfile()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Profile")
        }
        .onAppear {
            viewModel.loadProfile()
        }
    }
}

// MARK: - Profile ViewModel

@MainActor
public final class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let dashboardService: DashboardServiceProtocol
    
    public init(dashboardService: DashboardServiceProtocol = MockDashboardService()) {
        self.dashboardService = dashboardService
    }
    
    public func loadProfile() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let profile = try await dashboardService.fetchProfile()
                self.profile = profile
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
