//
//  DetailView.swift
//  Dashboard
//
//  Created by Janesh Suthar on 06/09/25.
//

import SwiftUI


public struct DetailView: View {
    let itemId: String
    @EnvironmentObject private var router: DashboardRouter
    
    public init(itemId: String) {
        self.itemId = itemId
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Item Header
                VStack(spacing: 16) {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Text("D")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        )
                    
                    Text("Detail View")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Item ID: \(itemId)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Content
                VStack(alignment: .leading, spacing: 16) {
                    Text("Details")
                        .font(.headline)
                    
                    Text("This is a detailed view for item with ID: \(itemId). Here you can display more information about the selected item.")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Detail")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        router.navigateBack()
                    }
                }
            }
        }
    }
}
