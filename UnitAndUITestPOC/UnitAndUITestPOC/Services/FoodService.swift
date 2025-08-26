//
//  FoodService.swift
//  UnitAndUITestPOC
//
//  Created by Janesh Suthar on 25/08/25.
//

import Foundation

protocol FoodServiceProtocol: Sendable {
    func fetchFoodItems(token: String) async throws -> [FoodItem]
}

actor FoodService: FoodServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService(session: URLSession.shared)) {
        self.networkService = networkService
    }
    
    func fetchFoodItems(token: String) async throws -> [FoodItem] {
        let endpoint = APIEndpoint.foodItems(token)
        let response: FoodItemsResponse = try await networkService.request(endpoint)
        return response.foodItems
    }
}
