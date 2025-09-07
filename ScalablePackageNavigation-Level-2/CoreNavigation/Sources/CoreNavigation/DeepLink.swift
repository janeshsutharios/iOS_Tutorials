//
//  DeepLink.swift
//  CoreNavigation
//
//  Created by Janesh Suthar on 06/09/25.
//

import Foundation

// MARK: - Deep Link Protocol
@available(iOS 16.0, macOS 13.0, *)
public protocol DeepLinkHandler: Sendable {
    /// Check if this handler can process the given URL
    func canHandle(url: URL) -> Bool
    
    /// Handle the deep link URL
    func handle(url: URL) async throws -> NavigationResult
}

// MARK: - Deep Link Coordinator
@available(iOS 16.0, macOS 13.0, *)
@MainActor
public final class DeepLinkCoordinator: ObservableObject, Sendable {
    private var handlers: [DeepLinkHandler] = []
    private let analytics: NavigationAnalytics
    
    public init(analytics: NavigationAnalytics = DefaultNavigationAnalytics()) {
        self.analytics = analytics
    }
    
    /// Register a deep link handler
    public func register(_ handler: DeepLinkHandler) {
        handlers.append(handler)
    }
    
    /// Process a deep link URL
    public func handle(url: URL) async -> NavigationResult {
        let startTime = Date()
        
        do {
            // Find the first handler that can process this URL
            guard let handler = handlers.first(where: { $0.canHandle(url: url) }) else {
                let error = NavigationError.deepLinkParsingFailed(url)
                await analytics.trackNavigationError(error)
                return .failure(error)
            }
            
            // Handle the deep link
            let result = try await handler.handle(url: url)
            
            // Track performance
            let duration = Date().timeIntervalSince(startTime)
            await analytics.trackNavigationPerformance(
                duration: duration,
                from: "deep_link",
                to: url.absoluteString
            )
            
            return result
            
        } catch {
            let navigationError = NavigationError.deepLinkParsingFailed(url)
            await analytics.trackNavigationError(navigationError)
            return .failure(navigationError)
        }
    }
    
    /// Check if any handler can process the URL
    public func canHandle(url: URL) -> Bool {
        return handlers.contains { $0.canHandle(url: url) }
    }
}

// MARK: - URL Scheme Deep Link Handler
@available(iOS 16.0, macOS 13.0, *)
public struct URLSchemeDeepLinkHandler: DeepLinkHandler {
    private let scheme: String
    private let host: String?
    private let handler: @Sendable (URL) async throws -> NavigationResult
    
    public init(
        scheme: String,
        host: String? = nil,
        handler: @escaping @Sendable (URL) async throws -> NavigationResult
    ) {
        self.scheme = scheme
        self.host = host
        self.handler = handler
    }
    
    public func canHandle(url: URL) -> Bool {
        guard url.scheme == scheme else { return false }
        if let expectedHost = host {
            return url.host == expectedHost
        }
        return true
    }
    
    public func handle(url: URL) async throws -> NavigationResult {
        return try await handler(url)
    }
}

// MARK: - Universal Link Handler
@available(iOS 16.0, macOS 13.0, *)
public struct UniversalLinkHandler: DeepLinkHandler {
    private let domain: String
    private let pathPrefix: String?
    private let handler: @Sendable (URL) async throws -> NavigationResult
    
    public init(
        domain: String,
        pathPrefix: String? = nil,
        handler: @escaping @Sendable (URL) async throws -> NavigationResult
    ) {
        self.domain = domain
        self.pathPrefix = pathPrefix
        self.handler = handler
    }
    
    public func canHandle(url: URL) -> Bool {
        guard let host = url.host, host == domain else { return false }
        if let prefix = pathPrefix {
            return url.path.hasPrefix(prefix)
        }
        return true
    }
    
    public func handle(url: URL) async throws -> NavigationResult {
        return try await handler(url)
    }
}
