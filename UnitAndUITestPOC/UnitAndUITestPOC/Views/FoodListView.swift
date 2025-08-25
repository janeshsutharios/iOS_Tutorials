//
//  FoodListView.swift
//  UnitAndUITestPOC
//
//  Created by Janesh Suthar on 25/08/25.
//

import SwiftUI

struct FoodListView: View {
    @StateObject private var viewModel = FoodViewModel()
    let accessToken: String
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.gray.opacity(0.1)
                    .ignoresSafeArea()
                
                VStack {
                    switch viewModel.foodState {
                    case .idle:
                        EmptyStateView(
                            title: "Ready to Explore",
                            message: "Tap refresh to load delicious food items",
                            systemImage: "fork.knife"
                        )
                        
                    case .loading:
                        LoadingView()
                        
                    case .loaded(let foodItems):
                        if foodItems.isEmpty {
                            EmptyStateView(
                                title: "No Food Items",
                                message: "No food items available at the moment",
                                systemImage: "tray"
                            )
                        } else {
                            ScrollView {
                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(foodItems) { foodItem in
                                        FoodItemCard(foodItem: foodItem)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                            }
                        }
                        
                    case .error(let message):
                        ErrorStateView(
                            message: message,
                            onRetry: {
                                Task {
                                    await viewModel.fetchFoodItems(token: accessToken)
                                }
                            }
                        )
                    }
                }
            }
            .navigationTitle("Food Menu")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.fetchFoodItems(token: accessToken)
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchFoodItems(token: accessToken)
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading delicious food...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

struct ErrorStateView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Oops! Something went wrong")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: onRetry) {
                Text("Try Again")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 120, height: 40)
                    .background(Color.blue)
                    .cornerRadius(20)
            }
        }
    }
}

#Preview {
    FoodListView(accessToken: "dummy-token")
}
