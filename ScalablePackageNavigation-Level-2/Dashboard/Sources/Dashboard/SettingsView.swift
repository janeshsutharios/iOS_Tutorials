//
//  SettingsView.swift
//  Dashboard
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI

public struct SettingsView: View {
    @EnvironmentObject private var router: DashboardRouter
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                Section("Account") {
                    SettingsRow(title: "Edit Profile", icon: "person.circle") {
                        // Handle edit profile
                    }
                    
                    SettingsRow(title: "Change Password", icon: "lock.circle") {
                        // Handle change password
                    }
                    
                    SettingsRow(title: "Privacy Settings", icon: "hand.raised.circle") {
                        // Handle privacy settings
                    }
                }
                
                Section("Preferences") {
                    SettingsRow(title: "Notifications", icon: "bell.circle") {
                        // Handle notifications
                    }
                    
                    SettingsRow(title: "Theme", icon: "paintbrush.circle") {
                        // Handle theme
                    }
                    
                    SettingsRow(title: "Language", icon: "globe") {
                        // Handle language
                    }
                }
                
                Section("Support") {
                    SettingsRow(title: "Help Center", icon: "questionmark.circle") {
                        // Handle help center
                    }
                    
                    SettingsRow(title: "Contact Support", icon: "envelope.circle") {
                        // Handle contact support
                    }
                    
                    SettingsRow(title: "About", icon: "info.circle") {
                        // Handle about
                    }
                }
                
                Section {
                    Button("Sign Out") {
                        // Handle sign out
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        router.navigateBack()
                    }
                }
            }
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
