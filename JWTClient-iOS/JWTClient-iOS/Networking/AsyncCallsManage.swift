// Async Call Management
import Foundation
import Combine
// Asynchronous / concurrent calls – executed in parallel:
// 1️⃣ Profile == 2️⃣ Restaurants == 3️⃣ Festivals == 4️⃣ Users

enum DashboardFetchResult {
    case profile(Result<Profile, Error>)
    case restaurants(Result<[Restaurant], Error>)
    case festivals(Result<[Festival], Error>)
    case users(Result<[User], Error>)
}
extension APIService {
    func fetchDashboardDataAsync(auth: AuthProviding) async -> DashboardData {
        var dashboard = DashboardData()

        await withTaskGroup(of: DashboardFetchResult.self) { group in
            // Profile
            group.addTask { @Sendable in
                let result: Result<Profile, Error> = await self.fetchWithRetry(auth: auth) { token in
                    try await self.fetchProfile(with: token)
                }
                return .profile(result)
            }

            // Restaurants
            group.addTask { @Sendable in
                let result: Result<[Restaurant], Error> = await self.fetchWithRetry(auth: auth) { token in
                    try await self.fetchRestaurants(with: token)
                }
                return .restaurants(result)
            }

            // Festivals
            group.addTask { @Sendable in
                let result: Result<[Festival], Error> = await self.fetchWithRetry(auth: auth) { token in
                    try await self.fetchFestivals(with: token)
                }
                return .festivals(result)
            }

            // Users
            group.addTask { @Sendable in
                let result: Result<[User], Error> = await self.fetchWithRetry(auth: auth) { token in
                    try await self.fetchUsers(with: token)
                }
                return .users(result)
            }

            for await result in group {
                switch result {
                case .profile(.success(let value)):
                    dashboard.profile = value
                case .restaurants(.success(let value)):
                    dashboard.restaurants = value
                case .festivals(.success(let value)):
                    dashboard.festivals = value
                case .users(.success(let value)):
                    dashboard.users = value

                case .profile(.failure(let error)):
                    dashboard.errors["profile"] = error
                case .restaurants(.failure(let error)):
                    dashboard.errors["restaurants"] = error
                case .festivals(.failure(let error)):
                    dashboard.errors["festivals"] = error
                case .users(.failure(let error)):
                    dashboard.errors["users"] = error
                }
            }
        }

        return dashboard
    }
}
