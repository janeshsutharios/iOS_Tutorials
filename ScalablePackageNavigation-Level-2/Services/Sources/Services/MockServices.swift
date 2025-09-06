//
//  MockServices.swift
//  Services
//
//  Created by Janesh Suthar on 06/09/25.
//

import Foundation

// MARK: - Mock Auth Service
public actor MockAuthService: AuthServiceProtocol {
    public var isAuthenticated: Bool = false
    
    public init() {}
    
    public func login(email: String, password: String) async throws -> Bool {
        try await Task.sleep(for: .seconds(1))
        
        if email.contains("@") && password.count >= 6 {
            isAuthenticated = true
            return true
        } else {
            throw AuthError.invalidCredentials
        }
    }
    
    public func signup(email: String, password: String) async throws -> Bool {
        try await Task.sleep(for: .seconds(1))
        
        if email.contains("@") && password.count >= 6 {
            isAuthenticated = true
            return true
        } else {
            throw AuthError.invalidCredentials
        }
    }
    
    public func logout() async throws -> Bool {
        try await Task.sleep(for: .milliseconds(500))
        isAuthenticated = false
        return true
    }
    
    public func forgotPassword(email: String) async throws -> Bool {
        try await Task.sleep(for: .seconds(1))
        
        if email.contains("@") {
            return true
        } else {
            throw AuthError.invalidEmail
        }
    }
    
    public func verifyCode(code: String) async throws -> Bool {
        try await Task.sleep(for: .seconds(1))
        
        if code == "123456" {
            return true
        } else {
            throw AuthError.invalidCode
        }
    }
}

// MARK: - Mock Dashboard Service
public final class MockDashboardService: DashboardServiceProtocol{
    public init() {}
    
    public func fetchDashboardData() async throws -> DashboardData {
        try await Task.sleep(for: .seconds(1))
        
        let items = [
            DashboardItem(id: "1", title: "Welcome", description: "Welcome to your dashboard"),
            DashboardItem(id: "2", title: "Analytics", description: "View your analytics"),
            DashboardItem(id: "3", title: "Settings", description: "Manage your settings")
        ]
        return DashboardData(id: "dashboard-1", title: "Dashboard", subtitle: "Your overview", items: items)
    }
    
    public func fetchProfile() async throws -> UserProfile {
        try await Task.sleep(for: .milliseconds(500))
        return UserProfile(id: "user-1", name: "John Doe", email: "john@example.com")
    }
    
    public func updateProfile(_ profile: UserProfile) async throws -> Bool {
        try await Task.sleep(for: .seconds(1))
        return true
    }
}

// MARK: - Mock Messages Service
public final class MockMessagesService: MessagesServiceProtocol {
    public init() {}
    
    public func fetchInbox() async throws -> [Message] {
        try await Task.sleep(for: .seconds(1))
        
        return [
            Message(id: "1", senderId: "user-2", receiverId: "user-1", content: "Hello there!", timestamp: Date()),
            Message(id: "2", senderId: "user-3", receiverId: "user-1", content: "How are you?", timestamp: Date().addingTimeInterval(-3600)),
            Message(id: "3", senderId: "user-4", receiverId: "user-1", content: "See you later!", timestamp: Date().addingTimeInterval(-7200))
        ]
    }
    
    public func fetchConversation(id: String) async throws -> [Message] {
        try await Task.sleep(for: .milliseconds(500))
        
        return [
            Message(id: "1", senderId: "user-1", receiverId: id, content: "Hi!", timestamp: Date().addingTimeInterval(-1800)),
            Message(id: "2", senderId: id, receiverId: "user-1", content: "Hello!", timestamp: Date().addingTimeInterval(-1200)),
            Message(id: "3", senderId: "user-1", receiverId: id, content: "How are you?", timestamp: Date().addingTimeInterval(-600))
        ]
    }
    
    public func sendMessage(to userId: String, content: String) async throws -> Bool {
        try await Task.sleep(for: .milliseconds(500))
        return true
    }
    
    public func searchMessages(query: String) async throws -> [Message] {
        try await Task.sleep(for: .milliseconds(500))
        
        return [
            Message(id: "1", senderId: "user-2", receiverId: "user-1", content: "Found message with \(query)", timestamp: Date())
        ]
    }
}

// MARK: - Error Types
public enum AuthError: Error, Sendable {
    case invalidCredentials
    case invalidEmail
    case invalidCode
    case networkError
}
