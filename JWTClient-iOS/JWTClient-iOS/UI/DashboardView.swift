import SwiftUI

// MARK: - Dashboard View
// Main dashboard that displays user data with support for both Async and Sync API modes
// Handles loading states, error display, and data presentation
struct DashboardView: View {
    // MARK: - Dependencies
    @EnvironmentObject var auth: AuthService  // Authentication state from parent
    let api: APIService                      // API service for data fetching
    
    // MARK: - View State
    @State private var data: DashboardData? = nil        // Dashboard data (profile, restaurants, etc.)
    @State private var isLoading = false                 // Loading state for all operations
    @State private var error: String? = nil              // Error message display
    @State private var selectedMode = 0                  // 0 = Async (concurrent), 1 = Sync (sequential)
    
    // MARK: - Task Management
    @State private var currentTask: Task<Void, Never>?   // Current async operation
    @State private var currentTaskID = UUID()            // Unique ID to prevent loading state conflicts
    
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
    
    // MARK: - Data Loading
    // Main data loading method that handles loading states and task coordination
    // Uses task IDs to prevent loading state conflicts when switching tabs rapidly
    private func loadData() async {
        // Generate unique task ID to track this specific operation
        let taskID = UUID()
        currentTaskID = taskID
        
        // Set loading state and clear previous data/errors
        isLoading = true
        error = nil
        data = nil  // Clear data immediately when loading starts
        
        // Fetch data based on selected mode
        await fetchData()
        
        // MARK: - Loading State Protection
        // Only update loading state if this is still the current task
        // This prevents cancelled tasks from interfering with new operations
        if currentTaskID == taskID {
            isLoading = false
        }
    }
    
    // MARK: - Data Fetching
    // Fetches dashboard data using either async (concurrent) or sync (sequential) mode
    // Async mode: All API calls run simultaneously for better performance
    // Sync mode: API calls run one after another (useful for debugging)
    private func fetchData() async {
        if selectedMode == 0 {
            // Async mode: Concurrent API calls for optimal performance
            data = await api.fetchDashboardDataAsync(auth: auth)
        } else {
            // Sync mode: Sequential API calls (easier to debug)
            data = await api.fetchDashboardDataSync(auth: auth)
        }
        // Extract error descriptions from data errors for display
        error = data.map {$0.errors.values.description}
    }
}

// MARK: - Profile Section
// Displays user profile information (username, role)
// Uses card modifier for consistent styling across all sections
struct ProfileSection: View {
    let profile: Profile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Profile").font(.headline)
            Text("Username: \(profile.username)")
            Text("Role: \(profile.role)")
        }
        .card()  // Consistent card styling for all dashboard sections
    }
}

// MARK: - Restaurants Section
// Displays list of available restaurants
// Uses ForEach to iterate through restaurant array
struct RestaurantsSection: View {
    let restaurants: [Restaurant]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Restaurants").font(.headline)
            ForEach(restaurants) { r in Text(r.name) }
        }
        .card()  // Consistent card styling
    }
}

// MARK: - Festivals Section
// Displays list of available festivals
// Uses ForEach to iterate through festival array
struct FestivalsSection: View {
    let festivals: [Festival]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Festivals").font(.headline)
            ForEach(festivals) { f in Text(f.name) }
        }
        .card()  // Consistent card styling
    }
}

// MARK: - Users Section
// Displays list of system users
// Uses ForEach to iterate through users array
struct UsersSection: View {
    let users: [User]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Users").font(.headline)
            ForEach(users) { u in Text(u.username) }
        }
        .card()  // Consistent card styling
    }
}
