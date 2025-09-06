//
//  Services.swift
//  Services
//
//  Created by Janesh Suthar on 06/09/25.
//

import Foundation
import Combine

// MARK: - Service Protocols

// MARK: - Auth Service Protocol
public protocol AuthServiceProtocol: Sendable {
    func login(email: String, password: String) async throws -> Bool
    func signup(email: String, password: String) async throws -> Bool
    func logout() async throws -> Bool
    func forgotPassword(email: String) async throws -> Bool
    func verifyCode(code: String) async throws -> Bool
    var isAuthenticated: Bool { get async }
}

// MARK: - Dashboard Service Protocol
public protocol DashboardServiceProtocol: Sendable {
    func fetchDashboardData() async throws -> DashboardData
    func fetchProfile() async throws -> UserProfile
    func updateProfile(_ profile: UserProfile) async throws -> Bool
}

// MARK: - Messages Service Protocol
public protocol MessagesServiceProtocol: Sendable {
    func fetchInbox() async throws -> [Message]
    func fetchConversation(id: String) async throws -> [Message]
    func sendMessage(to userId: String, content: String) async throws -> Bool
    func searchMessages(query: String) async throws -> [Message]
}

// MARK: - Data Models
public struct DashboardData: Sendable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let items: [DashboardItem]
    
    public init(id: String, title: String, subtitle: String, items: [DashboardItem]) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.items = items
    }
}

public struct DashboardItem: Sendable {
    public let id: String
    public let title: String
    public let description: String
    
    public init(id: String, title: String, description: String) {
        self.id = id
        self.title = title
        self.description = description
    }
}

public struct UserProfile: Sendable {
    public let id: String
    public let name: String
    public let email: String
    public let avatar: String?
    
    public init(id: String, name: String, email: String, avatar: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.avatar = avatar
    }
}

public struct Message: Sendable {
    public let id: String
    public let senderId: String
    public let receiverId: String
    public let content: String
    public let timestamp: Date
    public let isRead: Bool
    
    public init(id: String, senderId: String, receiverId: String, content: String, timestamp: Date, isRead: Bool = false) {
        self.id = id
        self.senderId = senderId
        self.receiverId = receiverId
        self.content = content
        self.timestamp = timestamp
        self.isRead = isRead
    }
}
