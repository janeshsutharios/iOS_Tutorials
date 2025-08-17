// Async Call Management
import Foundation
import Combine
// Asynchronous / concurrent calls – executed in parallel:
// 1️⃣ Profile, 2️⃣ Restaurants, 3️⃣ Festivals, 4️⃣ Users

extension APIService {
    func fetchDashboardDataAsync(auth: AuthProviding) async -> DashboardData {
        var dashboard = DashboardData()

        await withTaskGroup(of: (String, Result<Any, Error>).self) { group in
            // Profile
            group.addTask {
                let result = await self.fetchWithRetry(auth: auth) { token in
                    try await self.fetchProfile(with: token)
                }
                return ("profile", result.map { $0 as Any })
            }

            // Restaurants
            group.addTask {
                let result = await self.fetchWithRetry(auth: auth) { token in
                    try await self.fetchRestaurants(with: token)
                }
                return ("restaurants", result.map { $0 as Any })
            }

            // Festivals
            group.addTask {
                let result = await self.fetchWithRetry(auth: auth) { token in
                    try await self.fetchFestivals(with: token)
                }
                return ("festivals", result.map { $0 as Any })
            }

            // Users
            group.addTask {
                let result = await self.fetchWithRetry(auth: auth) { token in
                    try await self.fetchUsers(with: token)
                }
                return ("users", result.map { $0 as Any })
            }

            for await (key, result) in group {
                switch (key, result) {
                case ("profile", .success(let value as Profile)):
                    dashboard.profile = value
                case ("restaurants", .success(let value as [Restaurant])):
                    dashboard.restaurants = value
                case ("festivals", .success(let value as [Festival])):
                    dashboard.festivals = value
                case ("users", .success(let value as [User])):
                    dashboard.users = value
                case (let key, .failure(let error)):
                    dashboard.errors[key] = error
                default:
                    break
                }
            }
        }

        return dashboard
    }
}

