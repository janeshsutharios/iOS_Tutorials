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
import Profile

// MARK: - Main App View
struct ContentView: View {
    @StateObject private var coordinator: AppCoordinator
    
    init(coordinator: AppCoordinator) {
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
                    
                    ProfileNavigationContainer()
                        .tabItem {
                            Label("Profile", systemImage: "person")
                        }
                        .tag(AppCoordinator.AppTab.profile)
                }
            } else {
                // Auth flow
                AuthNavigationContainer {
                    coordinator.isAuthenticated = true
                }
            }
        }
        .environmentObject(coordinator)
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
        ContentView(coordinator: AppCoordinator())
    }
}
