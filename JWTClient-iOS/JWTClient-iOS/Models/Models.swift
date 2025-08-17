import Foundation

struct Profile: Codable { let username: String; let role: String }
struct Restaurant: Codable, Identifiable { let id: Int; let name: String }
struct Festival: Codable, Identifiable { let id: Int; let name: String }
struct User: Codable, Identifiable { let id: Int; let username: String }

struct DashboardData {
    var profile: Profile?
    var restaurants: [Restaurant]?
    var festivals: [Festival]?
    var users: [User]?
    
    var errors: [String: Error] = [:] // keep track of what failed
}
