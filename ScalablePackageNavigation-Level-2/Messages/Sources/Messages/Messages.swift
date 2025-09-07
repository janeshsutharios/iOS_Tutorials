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
@available(iOS 16.0, macOS 13.0, *)
public enum MessagesRoute: TypedRoute {
    case inbox
    case conversation(String)
    case compose
    case search
    
    public static var feature: AppFeature { .messages }
}

// MARK: - Messages Router

@available(iOS 16.0, macOS 13.0, *)
@MainActor
public final class MessagesRouter: BaseFeatureRouter<MessagesRoute> {
    public override init() {
        super.init()
    }
}

// MARK: - Messages Navigation Container

@available(iOS 16.0, macOS 13.0, *)
public struct MessagesNavigationContainer: View {
    @StateObject private var router: MessagesRouter
    
    public init(router: MessagesRouter? = nil) {
        self._router = StateObject(wrappedValue: router ?? MessagesRouter())
    }
    
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
