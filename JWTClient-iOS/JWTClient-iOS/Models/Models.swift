import Foundation

struct Profile: Codable { let username: String; let role: String }
struct Restaurant: Codable, Identifiable { let id: Int; let name: String }
struct Festival: Codable, Identifiable { let id: Int; let name: String }
struct User: Codable, Identifiable { let id: Int; let username: String }

struct DashboardData {
    let profile: Profile
    let restaurants: [Restaurant]
    let festivals: [Festival]
    let users: [User]
}
