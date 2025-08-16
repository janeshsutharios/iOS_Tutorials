import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var auth: AuthService
    let api: APIService
    @State private var data: DashboardData? = nil
    @State private var isLoading = false
    @State private var error: String? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if isLoading {
                    loadingSkeletons
                } else if let error {
                    Text(error).foregroundColor(.red)
                } else if let data {
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Logout") {
                    Task { await auth.logout() }
                }
            }
        }
        .task {
            await initialLoad()
        }
        .refreshable {
            await refreshLoad()
        }
    }
    
    private func initialLoad() async {
        isLoading = true
        error = nil
        await fetchData()
        isLoading = false
    }
    
    private func refreshLoad() async {
        error = nil
        await fetchData()
    }
    
    private func fetchData() async {
        do {
            data = try await api.fetchDashboardData(auth: auth)
        } catch {
            if case AppError.unauthorized = error {
                await auth.logout()
            }
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
    
    
    private func load() async {
        isLoading = true; error = nil
        do {
            data = try await api.fetchDashboardData(auth: auth)
        } catch {
            if case AppError.unauthorized = error {
                await auth.logout()
            }
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }
    
    var loadingSkeletons: some View {
        VStack(spacing: 12) {
            Text("Loading..."); SkeletonView(); SkeletonView(); SkeletonView()
        }
    }
}

struct ProfileSection: View {
    let profile: Profile
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Profile").font(.headline)
            Text("Username: \(profile.username)")
            Text("Role: \(profile.role)")
        }
        .card()
    }
}

struct RestaurantsSection: View {
    let restaurants: [Restaurant]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Restaurants").font(.headline)
            ForEach(restaurants) { r in Text(r.name) }
        }
        .card()
    }
}

struct FestivalsSection: View {
    let festivals: [Festival]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Festivals").font(.headline)
            ForEach(festivals) { f in Text(f.name) }
        }
        .card()
    }
}

struct UsersSection: View {
    let users: [User]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Users").font(.headline)
            ForEach(users) { u in Text(u.username) }
        }
        .card()
    }
}
