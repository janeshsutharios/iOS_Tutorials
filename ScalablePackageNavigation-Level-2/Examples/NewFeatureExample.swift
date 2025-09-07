//
//  NewFeatureExample.swift
//  ScalablePackageNavigation-Level-2
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI
import CoreNavigation

// MARK: - Example: Adding a New Feature
// This demonstrates how to add a new feature without modifying existing code

// 1. Define your feature's routes
public enum NewFeatureRoute: Hashable, Sendable {
    case main
    case detail(String)
    case settings
}

// 2. Create your feature router
@MainActor
public final class NewFeatureRouter: BaseFeatureRouter<NewFeatureRoute> {
    public override init() {
        super.init()
    }
}

// 3. Create your feature views
public struct NewFeatureMainView: View {
    @EnvironmentObject private var router: NewFeatureRouter
    @Environment(\.navigationEnvironment) private var navigationEnvironment
    
    public var body: some View {
        VStack {
            Text("New Feature Main View")
                .font(.title)
            
            Button("Go to Detail") {
                router.navigate(to: .detail("Example Detail"))
            }
            
            Button("Go to Settings") {
                router.navigate(to: .settings)
            }
            
            Button("Navigate to Dashboard") {
                // Cross-feature navigation
                navigationEnvironment?.navigateToFeature("dashboard", route: DashboardRoute.home)
            }
        }
        .padding()
    }
}

public struct NewFeatureDetailView: View {
    let item: String
    @EnvironmentObject private var router: NewFeatureRouter
    
    public var body: some View {
        VStack {
            Text("Detail for: \(item)")
                .font(.title)
            
            Button("Back") {
                router.navigateBack()
            }
        }
        .padding()
    }
}

public struct NewFeatureSettingsView: View {
    @EnvironmentObject private var router: NewFeatureRouter
    
    public var body: some View {
        VStack {
            Text("New Feature Settings")
                .font(.title)
            
            Button("Back") {
                router.navigateBack()
            }
        }
        .padding()
    }
}

// 4. Create your navigation container
public struct NewFeatureNavigationContainer: View {
    @StateObject private var router: NewFeatureRouter
    
    public init(router: NewFeatureRouter? = nil) {
        self._router = StateObject(wrappedValue: router ?? NewFeatureRouter())
    }
    
    public var body: some View {
        NavigationStack(path: $router.navigationPath) {
            NewFeatureMainView()
                .navigationDestination(for: NewFeatureRoute.self) { route in
                    destinationView(for: route)
                }
        }
        .environmentObject(router)
        .environment(\.navigationEnvironment, router)
    }
    
    @ViewBuilder
    private func destinationView(for route: NewFeatureRoute) -> some View {
        switch route {
        case .main:
            NewFeatureMainView()
        case .detail(let item):
            NewFeatureDetailView(item: item)
        case .settings:
            NewFeatureSettingsView()
        }
    }
}

// MARK: - How to Integrate the New Feature
/*
 To add this new feature to your app, you would:

 1. Add the new feature to your AppCoordinator:
    - Add a new tab case: case newFeature
    - Register the feature in registerFeatures()
    - Add navigation handling in handleCrossFeatureNavigation()

 2. Update your ContentView:
    - Add a new tab item for the new feature
    - Pass the router from the coordinator

 3. That's it! No other existing code needs to be modified.

 This demonstrates the scalability of the architecture:
 - Each feature is self-contained
 - No tight coupling between features
 - Easy to add/remove features
 - Cross-feature navigation works automatically
 - Dependency injection handles all services
 */
