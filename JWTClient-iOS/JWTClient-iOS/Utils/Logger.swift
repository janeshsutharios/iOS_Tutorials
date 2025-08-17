import Foundation
import os

// MARK: - Logger Implementation

/// Thread-safe logging utility using Apple's unified logging system
@MainActor
final class AppLogger {
    // MARK: - Configuration
    private enum Constants {
        static let subsystem = "com.example.JWTClientPro"
    }
    
    // MARK: - Log Categories
    enum Category: String, CaseIterable, Sendable {
        case network, auth, ui, keychain
    }
    
    // MARK: - Properties
    private static let shared = AppLogger()
    private var loggers: [Category: Logger] = [:]
    
    private init() {
        // Pre-initialize loggers for all categories
        Category.allCases.forEach { category in
            loggers[category] = Logger(subsystem: Constants.subsystem,
                                      category: category.rawValue)
        }
    }
    
    // MARK: - Public Interface
    
    /// Main logging method
    nonisolated static func log(
        _ message: String,
        category: Category = .ui,
        type: OSLogType = .default,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        Task { await shared._log(message, category: category, type: type, file: file, function: function, line: line) }
    }
    
    /// Network-specific logging
    nonisolated static func network(
        _ message: String,
        type: OSLogType = .info,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, category: .network, type: type, file: file, function: function, line: line)
    }
    
    /// Info-level logging
    nonisolated static func info(
        _ message: String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, category: .ui, type: .info, file: file, function: function, line: line)
    }
    
    /// Error-level logging
    nonisolated static func error(
        _ message: String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, category: .ui, type: .error, file: file, function: function, line: line)
    }
    
    // MARK: - Private Implementation
    private func _log(
        _ message: String,
        category: Category,
        type: OSLogType,
        file: String,
        function: String,
        line: Int
    ) {
        let logger = loggers[category] ?? Logger(subsystem: Constants.subsystem, category: category.rawValue)
        let formattedMessage = "[\(file):\(line)] \(function) - \(message)"
        
        switch type {
        case .default, .debug:
            logger.debug("\(formattedMessage, privacy: .public)")
        case .info:
            logger.info("\(formattedMessage, privacy: .public)")
        case .error, .fault:
            logger.error("\(formattedMessage, privacy: .public)")
        default:
            logger.log(level: type, "\(formattedMessage, privacy: .public)")
        }
    }
}
