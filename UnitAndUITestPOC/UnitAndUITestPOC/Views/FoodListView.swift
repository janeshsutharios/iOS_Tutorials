//
//  FoodListView.swift
//  UnitAndUITestPOC
//
//  Created by Janesh Suthar on 25/08/25.
//

import SwiftUI

struct FoodListView: View {
    @StateObject private var viewModel = FoodViewModel()
    @Environment(\.colorScheme) var colorScheme
    let accessToken: String
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                colorScheme.secondaryBackground
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
                            .foregroundColor(colorScheme.primaryAccent)
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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: colorScheme.loadingTint))
            
            Text("Loading delicious food...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}

struct EmptyStateView: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let message: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundColor(colorScheme.secondaryText)
            
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
    @Environment(\.colorScheme) var colorScheme
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(colorScheme.warningColor)
            
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
                            .background(colorScheme.primaryAccent)
                            .cornerRadius(20)
                    }
        }
    }
}

#Preview {
    FoodListView(accessToken: "dummy-token")
}
