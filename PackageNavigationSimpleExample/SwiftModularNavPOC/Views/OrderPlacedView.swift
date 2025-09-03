//
//  OrderPlacedView.swift
//  PackageNavigation
//
//  Created by Janesh Suthar on 08/08/25.
//
// You can create package for OrderPlacedView too just like AddToCartView, Here I have added only to demonstrate Navigation from App->Lib->App

import SwiftUI
import NavigationLib

struct OrderPlacedView: View {
    @EnvironmentObject var navModel: NavigationModel

    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
                .padding()
            
            Text("Order Placed!")
                .font(.title)
            
            Text("Thank you for your purchase")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .navigationTitle("Order Confirmation")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    // Navigate directly to DashboardView
                    navModel.appRoute.removeAll()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Home")
                    }
                }
            }
        }
    }
}
