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

//extension APIService {
//private func fetchWithRetry<T>(auth: AuthProviding,_ operation: @escaping (_ token: String) async throws -> T) async -> Result<T, Error> {
//    
//    do {
//        let newToken = try await auth.validAccessToken()
//        return .success(try await operation(newToken))
//    } catch AppError.unauthorized {
//        // Token is invalid/expired and refresh failed - logout user
//        await auth.logout()
//        return .failure(AppError.unauthorized)
//    } catch {
//        return .failure(error)
//    }
//    
//}
//
//    func fetchDashboardData(auth: AuthProviding) async -> DashboardData {
//        var dashboard = DashboardData()
//
//        // 1️⃣ Profile
//        do {
//            dashboard.profile = try await fetchWithRetry(auth: auth) { token in
//                try await self.fetchProfile(with: token)
//            }
//        } catch {
//            dashboard.errors["profile"] = error
//        }
//
//        // 2️⃣ Restaurants
//        do {
//            dashboard.restaurants = try await fetchWithRetry(auth: auth) { token in
//                try await self.fetchRestaurants(with: token)
//            }
//        } catch {
//            dashboard.errors["restaurants"] = error
//        }
//
//        // 3️⃣ Festivals
//        do {
//            dashboard.festivals = try await fetchWithRetry(auth: auth) { token in
//                try await self.fetchFestivals(with: token)
//            }
//        } catch {
//            dashboard.errors["festivals"] = error
//        }
//
//        // 4️⃣ Users
//        do {
//            dashboard.users = try await fetchWithRetry(auth: auth) { token in
//                try await self.fetchUsers(with: token)
//            }
//        } catch {
//            dashboard.errors["users"] = error
//        }
//
//        return dashboard
//    }
//}
//
