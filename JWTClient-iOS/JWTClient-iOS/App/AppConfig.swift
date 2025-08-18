import Foundation

// Environment types for different deployment stages
enum Environment: String, CaseIterable {
    case dev, staging, prod
}

// Configuration loaded from environment-specific JSON files
struct AppConfig: Codable, Sendable {
    let name: String
    let baseURL: String
    let timeoutSeconds: TimeInterval
    
    // Override for testing/debugging specific environments
    @MainActor static var overrideEnvironment: Environment? = nil
    
    // Load config from bundle JSON file
    static func load(for env: Environment) -> AppConfig {
        let filename: String
        switch env {
        case .dev: filename = "config.dev"
        case .staging: filename = "config.staging"
        case .prod: filename = "config.prod"
        }
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let cfg = try? JSONDecoder().decode(AppConfig.self, from: data) else {
            fatalError("Missing or invalid config file for \(env)")
        }
        return cfg
    }
}
