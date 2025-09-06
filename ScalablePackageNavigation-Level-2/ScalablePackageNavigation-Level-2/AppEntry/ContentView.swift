//
//  ContentView.swift
//  ScalablePackageNavigation-Level-2
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI
import Auth
import Dashboard
import Messages

// MARK: - Main App View
struct ContentView: View {
    @StateObject private var coordinator: AppCoordinator
    
    init(coordinator: AppCoordinator = AppCoordinator()) {
        _coordinator = StateObject(wrappedValue: coordinator)
    }
    
    var body: some View {
        Group {
            if coordinator.isAuthenticated {
                // Main app with tabs
                TabView(selection: $coordinator.activeTab) {
                    DashboardNavigationContainer()
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                        .tag(AppCoordinator.AppTab.dashboard)
                    
                    MessagesNavigationContainer()
                        .tabItem {
                            Label("Messages", systemImage: "message")
                        }
                        .tag(AppCoordinator.AppTab.messages)
                    
                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person")
                        }
                        .tag(AppCoordinator.AppTab.profile)
                }
            } else {
                // Auth flow
                AuthNavigationContainer()
            }
        }
        .environmentObject(coordinator)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
