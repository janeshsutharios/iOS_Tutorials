import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var auth: AuthService
    let api: APIService
    @State private var data: DashboardData? = nil
    @State private var isLoading = false
    @State private var error: String? = nil
    @State private var selectedMode = 0 // 0 = Async, 1 = Sync
    @State private var currentTask: Task<Void, Never>?
    @State private var currentTaskID = UUID()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Simple Segment Control
                Picker("API Mode", selection: $selectedMode) {
                    Text("⚡️ Async").tag(0)
                    Text("🔄 Sync").tag(1)
                }
                
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .onChange(of: selectedMode) { _, _ in
                    currentTask?.cancel()
                    currentTask = Task { await loadData() }
                }

                if let error {
                    Text(error).foregroundColor(.red)
                } else if let data {
                    if let profile = data.profile {
                        ProfileSection(profile: profile)
                    }
                    if let restaurants = data.restaurants {
                        RestaurantsSection(restaurants: restaurants)
                    }
                    if let festivals = data.festivals {
                        FestivalsSection(festivals: festivals)
                    }
                    if let users = data.users {
                        UsersSection(users: users)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Dashboard")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .red))
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Logout") {
                    Task { await auth.logout() }
                }
                .foregroundColor(.red)
            }
        }
        .task {
            currentTask = Task { await loadData() }
        }
        .refreshable {
            currentTask?.cancel()
            currentTask = Task { await loadData() }
        }
    }
    
    private func loadData() async {
        let taskID = UUID()
        currentTaskID = taskID
        
        isLoading = true
        error = nil
        data = nil  // Clear data immediately when loading starts
        
        await fetchData()
        
        // Only update loading state if this is still the current task
        if currentTaskID == taskID {
            isLoading = false
        }
    }
    
    private func fetchData() async {
        if selectedMode == 0 {
            data = await api.fetchDashboardDataAsync(auth: auth)
        } else {
            data = await api.fetchDashboardDataSync(auth: auth)
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
