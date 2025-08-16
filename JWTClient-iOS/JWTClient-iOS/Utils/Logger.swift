import Foundation
import os

enum LogCategory: String {
    case network, auth, ui, keychain
}

struct AppLogger {
    static func log(_ message: String, category: LogCategory = .ui, type: OSLogType = .default) {
        let logger = Logger(subsystem: "com.example.JWTClientPro", category: category.rawValue)
        logger.log(level: type, "\(message)")
    }
    
    // Simple network logging for web calls
    static func network(_ message: String, category: OSLogType = .info) {
        logger.log(level: category, "\(appName): \(message, privacy: .public)")
    }

}

let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "MyApp"
let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.janesh.JWTClient-iOS", category: "network")

