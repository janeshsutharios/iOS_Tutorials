//
//  DashboardView.swift
//  Concurrancy1
//
//  Created by Janesh Suthar on 16/08/25.
//


import SwiftUI

struct DashboardView: View {
    @State private var dashboardData: DashboardData?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView()
                } else if let error = errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                } else if let data = dashboardData {
                    ProfileSection(profile: data.profile)
                    RestaurantsSection(restaurants: data.restaurants)
                    FestivalsSection(festivals: data.festivals)
                    UsersSection(users: data.users)
                }
            }
            .padding()
        }
        .navigationTitle("Dashboard")
        .toolbar {
            Button("Logout") {
                Task {
                    try await AuthService.shared.logout()
                }
            }
        }
        .task {
            await loadData()
        }
    }
    
    private func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            dashboardData = try await APIService.shared.fetchDashboardData()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

// Subviews for each section
struct ProfileSection: View {
    let profile: Profile
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Profile")
                .font(.headline)
            Text("Username: \(profile.username)")
            Text("Role: \(profile.role)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct RestaurantsSection: View {
    let restaurants: [Restaurant]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Restaurants")
                .font(.headline)
            
            ForEach(restaurants) { restaurant in
                Text(restaurant.name)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct FestivalsSection: View {
    let festivals: [Festival]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Festivals")
                .font(.headline)
            
            ForEach(festivals) { festival in
                Text(festival.name)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct UsersSection: View {
    let users: [User]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Users")
                .font(.headline)
            
            ForEach(users) { user in
                Text(user.username)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}