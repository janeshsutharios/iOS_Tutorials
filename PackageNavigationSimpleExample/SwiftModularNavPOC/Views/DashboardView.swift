//
//  SwiftUIView.swift
//  PackageNavigation
//
//  Created by Janesh Suthar on 08/08/25.
//

import SwiftUI
import ManageCartLib
import NavigationLib

@main
struct NavigationDemoApp: App {
    
    @StateObject private var navigationModel = NavigationModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                DashboardView()
                    .environmentObject(navigationModel)
            }
        }
    }
}

struct DashboardView: View {
    
    @EnvironmentObject var navModel: NavigationModel
    
    var body: some View {
        NavigationStack(path: $navModel.appRoute) {
            VStack {
                Button("Add To Cart") {
                    navModel.appRoute.append(.cart(.addToCart))
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .cart(_):
                    AddToCartView()
                case .orders(_):
                    OrderPlacedView()
                default: EmptyView()
                }
            }
            .navigationTitle("Dashboard")
        }
    }
}

#Preview {
    DashboardView()
}
