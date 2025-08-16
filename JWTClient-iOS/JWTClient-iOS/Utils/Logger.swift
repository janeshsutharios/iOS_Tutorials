import Foundation
import os

// Log categories for organizing messages in Console.app
enum LogCategory: String {
    case network, auth, ui, keychain
}

// Simple logging utility using Apple's unified logging system
struct AppLogger {
    static func log(_ message: String, category: LogCategory = .ui, type: OSLogType = .default) {
        let logger = Logger(subsystem: "com.example.JWTClientPro", category: category.rawValue)
        logger.log(level: type, "\(appName+message)")
    }
    
    // Convenience method for network logging
    static func network(_ message: String, category: OSLogType = .info) {
        logger.log(level: category, "\(appName): \(message, privacy: .public)")
    }
    
    static func info(_ message: String) {
        logger.info("\(appName): \(message, privacy: .public)")
    }
    
    static func error(_ message: String) {
        logger.error("\(appName): \(message, privacy: .public)")
    }
}

// App name for log identification
let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "MyApp"

// Dedicated logger for network operations
let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.janesh.JWTClient-iOS", category: "network")

