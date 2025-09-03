//
//  Swift_Xcode_26App.swift
//  Swift-Xcode-26
//
//  Created by Janesh Suthar on 19/08/25.
//

import SwiftUI
import Combine
@main
struct Swift_Xcode_26App: App {
    
    @StateObject private var model = NavigationModel()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(model)
        }
    }
}

#Preview {
    RootView()
}

final class NavigationModel: ObservableObject {
    @Published var path: [AppDestination] = []
    
    // MARK: - Helpers
    func push(_ destination: AppDestination) {
        path.append(destination)
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func popToRoot() {
        path.removeAll()//  // back to root
    }
    
    func setPath(_ destinations: [AppDestination]) {
        path = destinations
    }
}

// MARK: - Destination Enum
// This keeps your navigation strongly typed.
enum AppDestination: Hashable {
    case dashboard
    case profile(userID: Int)
    case cart
    case appSettings
}


struct RootView: View {
    @EnvironmentObject var navModel: NavigationModel
    
    var body: some View {
        NavigationStack(path: $navModel.path) {
            DashboardView()
                .navigationDestination(for: AppDestination.self) { destination in
                    switch destination {
                    case .dashboard:
                        DashboardView()
                    case .profile(let userID):
                        ProfileView(userID: userID)
                    case .cart:
                        CartView()
                    case .appSettings:
                        SettingsView()
                    }
                }
        }
    }
}


// MARK: - Views
struct DashboardView: View {
    @EnvironmentObject var navModel: NavigationModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("📊 Dashboard")
                .font(.largeTitle)
            
            Button("Go to Profile (user 42)") {
                navModel.push(.profile(userID: 42))
            }
            
            Button("Go to Cart") {
                navModel.push(.cart)
            }
            
            Button("Open Settings") {
                navModel.push(.appSettings)
            }
        }
        .padding()
    }
}

struct SettingsView: View {
    @EnvironmentObject var navModel: NavigationModel
    
    var body: some View {
        VStack(spacing: 20) {
            Button {
                navModel.pop()
            } label: {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
            }
            
            Text("⚙️ Settings")
                .font(.title)
                .padding()
            
            Button("Go to Home") {
                navModel.popToRoot()
            }
        }
    }
}


struct ProfileView: View {
    let userID: Int
    var body: some View {
        VStack(spacing: 20) {
    
            Text("👤 Profile of user \(userID)")
                .font(.title)
            
            NavigationLink(value: AppDestination.cart) {
                Text("Go to Cart from Profile")
            }
        }
        .padding()
    }
}

struct CartView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🛒 Cart")
                .font(.title)
            
            NavigationLink(value: AppDestination.appSettings) {
                Text("Go to Settings from Cart")
            }
        }
        .padding()
    }
}

/*
 path.append(.profile(userID: 42))  // push
 path.removeLast()                  // pop
 path.removeAll()                   // back to root
 */
