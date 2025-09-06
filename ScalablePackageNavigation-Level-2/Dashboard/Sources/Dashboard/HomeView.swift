//
//  HomeView.swift
//  Dashboard
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI
import Services
import Combine

public struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var router: DashboardRouter
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading dashboard...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let dashboardData = viewModel.dashboardData {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Header
                            VStack(alignment: .leading) {
                                Text(dashboardData.title)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                Text(dashboardData.subtitle)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            
                            // Dashboard Items
                            LazyVStack(spacing: 12) {
                                ForEach(dashboardData.items, id: \.id) { item in
                                    DashboardItemCard(item: item) {
                                        router.navigate(to: .detail(item.id))
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                } else if let error = viewModel.errorMessage {
                    VStack {
                        Text("Error loading dashboard")
                            .font(.headline)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                        Button("Retry") {
                            viewModel.loadDashboardData()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Profile") {
                        router.navigate(to: .profile)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadDashboardData()
        }
    }
}

// MARK: - Dashboard Item Card
struct DashboardItemCard: View {
    let item: DashboardItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(item.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Home ViewModel
@MainActor
public final class HomeViewModel: ObservableObject {
    @Published var dashboardData: DashboardData?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let dashboardService: DashboardServiceProtocol
    
    public init(dashboardService: DashboardServiceProtocol = MockDashboardService()) {
        self.dashboardService = dashboardService
    }
    
    public func loadDashboardData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let data = try await dashboardService.fetchDashboardData()
                dashboardData = data
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
