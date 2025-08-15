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
}
