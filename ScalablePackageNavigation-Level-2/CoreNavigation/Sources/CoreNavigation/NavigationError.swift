//
//  NavigationError.swift
//  CoreNavigation
//
//  Created by Janesh Suthar on 06/09/25.
//

import Foundation

// MARK: - Navigation Error Types
@available(iOS 16.0, macOS 13.0, *)
public enum NavigationError: Error, Sendable {
    case featureNotRegistered(AppFeature)
    case invalidRouteType(AppFeature, expected: String, actual: String)
    case navigationHandlerNotFound(AppFeature)
    case routeValidationFailed(AppFeature, route: String)
    case deepLinkParsingFailed(URL)
    case navigationStateCorrupted(String)
    
    public var localizedDescription: String {
        switch self {
        case .featureNotRegistered(let feature):
            return "Feature '\(feature.rawValue)' is not registered"
        case .invalidRouteType(let feature, let expected, let actual):
            return "Invalid route type for feature '\(feature.rawValue)': expected \(expected), got \(actual)"
        case .navigationHandlerNotFound(let feature):
            return "Navigation handler not found for feature '\(feature.rawValue)'"
        case .routeValidationFailed(let feature, let route):
            return "Route validation failed for feature '\(feature.rawValue)': \(route)"
        case .deepLinkParsingFailed(let url):
            return "Failed to parse deep link: \(url)"
        case .navigationStateCorrupted(let reason):
            return "Navigation state corrupted: \(reason)"
        }
    }
}

// MARK: - Navigation Analytics Protocol
@available(iOS 16.0, macOS 13.0, *)
public protocol NavigationAnalytics: Sendable {
    /// Track successful navigation
    func trackNavigation(from: String, to: String, route: String) async
    
    /// Track navigation error
    func trackNavigationError(_ error: NavigationError) async
    
    /// Track navigation performance
    func trackNavigationPerformance(duration: TimeInterval, from: String, to: String) async
}

// MARK: - Default Navigation Analytics
@available(iOS 16.0, macOS 13.0, *)
public final class DefaultNavigationAnalytics: NavigationAnalytics {
    public init() {}
    
    public func trackNavigation(from: String, to: String, route: String) async {
        print("🧭 Navigation: \(from) → \(to) (route: \(route))")
    }
    
    public func trackNavigationError(_ error: NavigationError) async {
        print("❌ Navigation Error: \(error.localizedDescription)")
    }
    
    public func trackNavigationPerformance(duration: TimeInterval, from: String, to: String) async {
        print("⏱️ Navigation Performance: \(from) → \(to) took \(duration)s")
    }
}

// MARK: - Navigation Result
@available(iOS 16.0, macOS 13.0, *)
public enum NavigationResult: Sendable {
    case success
    case failure(NavigationError)
}
