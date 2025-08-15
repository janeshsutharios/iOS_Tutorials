//
//  JWTApp.swift
//  Concurrancy1
//
//  Created by Janesh Suthar on 16/08/25.
//


import SwiftUI

@main
struct JWTApp: App {
    @StateObject private var auth = AuthService.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if auth.isAuthenticated {
                    DashboardView()
                } else {
                    LoginView()
                }
            }
        }
    }
}