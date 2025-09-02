//
//  OrderPlacedView.swift
//  PackageNavigation
//
//  Created by Janesh Suthar on 08/08/25.
//

import SwiftUI

struct OrderPlacedView: View {
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
    }
}
