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
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                DashboardView()
            }
        }
    }
}

struct DashboardView: View {
    @State private var path = [AppRoute]()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Button("Add To Cart") {
                    path.append(.cart(.addToCart))
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .cart(_):
                    AddToCartView(path: $path)
                case .orders(_):
                    OrderPlacedView(path: $path)
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
