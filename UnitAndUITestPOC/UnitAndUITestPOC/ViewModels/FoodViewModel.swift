//
//  FoodViewModel.swift
//  UnitAndUITestPOC
//
//  Created by Janesh Suthar on 25/08/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class FoodViewModel: ObservableObject {
    @Published var foodState: FoodLoadingState = .idle
    
    private let foodService: FoodServiceProtocol
    
    init(foodService: FoodServiceProtocol = FoodService()) {
        self.foodService = foodService
    }
    
    var isLoading: Bool {
        if case .loading = foodState {
            return true
        }
        return false
    }
    
    var foodItems: [FoodItem] {
        if case .loaded(let items) = foodState {
            return items
        }
        return []
    }
    
    var errorMessage: String? {
        if case .error(let message) = foodState {
            return message
        }
        return nil
    }
    
    func fetchFoodItems(token: String) async {
        guard !token.isEmpty else {
            foodState = .error("Invalid token")
            return
        }
        
        foodState = .loading
        
        do {
            let items = try await foodService.fetchFoodItems(token: token)
            foodState = .loaded(items)
        } catch let error as NetworkError {
            foodState = .error(error.errorDescription ?? "Failed to fetch food items")
        } catch {
            foodState = .error("An unexpected error occurred")
        }
    }
    
    func resetState() {
        foodState = .idle
    }
}
