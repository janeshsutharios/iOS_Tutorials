//
//  Messages.swift
//  Messages
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI
import CoreNavigation
import Services

// MARK: - Messages Route
public enum MessagesRoute: Hashable, Sendable {
    case inbox
    case conversation(String)
    case compose
    case search
}

// MARK: - Messages Router
@MainActor
public final class MessagesRouter: BaseRouter<MessagesRoute> {
    public override init() {
        super.init()
    }
}

// MARK: - Messages Navigation Container
public struct MessagesNavigationContainer: View {
    @StateObject private var router = MessagesRouter()
    
    public init() {}
    
    public var body: some View {
        NavigationStack(path: $router.navigationPath) {
            InboxView()
                .navigationDestination(for: MessagesRoute.self) { route in
                    destinationView(for: route)
                }
        }
        .environmentObject(router)
    }
    
    @ViewBuilder
    private func destinationView(for route: MessagesRoute) -> some View {
        switch route {
        case .inbox:
            InboxView()
        case .conversation(let userId):
            ConversationView(userId: userId)
        case .compose:
            ComposeView()
        case .search:
            SearchView()
        }
    }
}
