//
//  ContentView.swift
//  ScalablePackageNavigation-Level-2
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI
import CoreNavigation
import Auth
import Dashboard
import Messages
import Profile
import Services

// MARK: - Main App View
@available(iOS 16.0, macOS 13.0, *)
struct ContentView: View {
    @StateObject private var coordinator: AppCoordinator
    @State private var container = DefaultDependencyContainer()
    
    init(coordinator: AppCoordinator? = nil) {
        let container = DefaultDependencyContainer()
        self._container = .init(initialValue: container)
        
        // Register default services asynchronously
        Task {
            await container.register(AuthServiceProtocol.self) { MockAuthService() }
            await container.register(DashboardServiceProtocol.self) { MockDashboardService() }
            await container.register(MessagesServiceProtocol.self) { MockMessagesService() }
        }
        
        self._coordinator = StateObject(wrappedValue: coordinator ?? AppCoordinator(container: container))
    }
    
    var body: some View {
        Group {
            if coordinator.isAuthenticated {
                // Main app with tabs - each tab has its own independent navigation stack
                TabView(selection: $coordinator.activeTab) {
                    DashboardNavigationContainer(router: coordinator.dashboardRouter)
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                        .tag(AppCoordinator.AppTab.dashboard)
                    
                    MessagesNavigationContainer(router: coordinator.messagesRouter)
                        .tabItem {
                            Label("Messages", systemImage: "message")
                        }
                        .tag(AppCoordinator.AppTab.messages)
                    
                    ProfileNavigationContainer(router: coordinator.profileRouter)
                        .tabItem {
                            Label("Profile", systemImage: "person")
                        }
                        .tag(AppCoordinator.AppTab.profile)
                }
            } else {
                // Auth flow
                AuthNavigationContainer(router: coordinator.authRouter) {
                    coordinator.isAuthenticated = true
                }
            }
        }
        .environmentObject(coordinator)
        .environment(\.dependencyContainer, container)
        .environment(\.navigationEnvironment, coordinator)
        .onAppear {
            print("ContentView appeared. isAuthenticated: \(coordinator.isAuthenticated)")
        }
        .onChange(of: coordinator.isAuthenticated) { oldValue, newValue in
            print("Authentication state changed to: \(newValue)")
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
       // ContentView()
    }
}
