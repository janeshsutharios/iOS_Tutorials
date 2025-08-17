//
//  SyncCallManagement.swift
//  JWTClient-iOS
//
//  Created by Janesh Suthar on 16/08/25.
//
import Foundation
import Combine
// Synchronous / sequential calls – executed one after another:
// 1️⃣ Profile -> 2️⃣ Restaurants -> 3️⃣ Festivals -> 4️⃣ Users

extension APIService {
    
    func fetchDashboardDataSync(auth: AuthProviding) async -> DashboardData {
        var dashboard = DashboardData()
        
        // 1️⃣ Profile
        let profileResult = await fetchWithRetry(auth: auth) { token in
            try await self.fetchProfile(with: token)
        }
        switch profileResult {
        case .success(let profile):
            dashboard.profile = profile
        case .failure(let error):
            dashboard.errors["profile"] = error
        }
        
        // 2️⃣ Restaurants
        let restaurantsResult = await fetchWithRetry(auth: auth) { token in
            try await self.fetchRestaurants(with: token)
        }
        switch restaurantsResult {
        case .success(let restaurants):
            dashboard.restaurants = restaurants
        case .failure(let error):
            dashboard.errors["restaurants"] = error
        }
        
        // 3️⃣ Festivals
        let festivalsResult = await fetchWithRetry(auth: auth) { token in
            try await self.fetchFestivals(with: token)
        }
        switch festivalsResult {
        case .success(let festivals):
            dashboard.festivals = festivals
        case .failure(let error):
            dashboard.errors["festivals"] = error
        }
        
        // 4️⃣ Users
        let usersResult = await fetchWithRetry(auth: auth) { token in
            try await self.fetchUsers(with: token)
        }
        switch usersResult {
        case .success(let users):
            dashboard.users = users
        case .failure(let error):
            dashboard.errors["users"] = error
        }
        
        return dashboard
    }
}
