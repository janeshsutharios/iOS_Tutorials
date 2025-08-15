import Foundation

enum Environment: String, CaseIterable {
    case dev, staging, prod
}

struct AppConfig: Codable {
    let name: String
    let baseURL: String
    let timeoutSeconds: TimeInterval
    
    static var overrideEnvironment: Environment? = nil
    
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
