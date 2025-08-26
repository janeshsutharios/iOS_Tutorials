//
//  FoodItemCard.swift
//  UnitAndUITestPOC
//
//  Created by Janesh Suthar on 25/08/25.
//

import SwiftUI

struct FoodItemCard: View {
    @Environment(\.colorScheme) var colorScheme
    let foodItem: FoodItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Food image
            AsyncImage(url: URL(string: foodItem.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(colorScheme.loadingBackground)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: colorScheme.loadingTint))
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure:
                    Rectangle()
                        .fill(colorScheme.loadingBackground)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(colorScheme.secondaryText)
                        )
                @unknown default:
                    Rectangle()
                        .fill(colorScheme.loadingBackground)
                }
            }
            .frame(height: 150)
            .clipped()
            .cornerRadius(12)
            
            // Food details
            VStack(alignment: .leading, spacing: 8) {
                // Title and price
                HStack {
                    Text(foodItem.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    Text(foodItem.formattedPrice)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme.successColor)
                }
                
                // Category
                Text(foodItem.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(colorScheme.primaryAccent.opacity(0.2))
                    .cornerRadius(8)
                
                // Description
                Text(foodItem.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(colorScheme.cardBackground)
        .cornerRadius(16)
        .shadow(color: colorScheme.shadowColor, radius: 8, x: 0, y: 4)
    }
}

#Preview {
    FoodItemCard(foodItem: FoodItem(
        id: 1,
        name: "Classic Cheeseburger",
        description: "Juicy beef patty with cheese, fresh lettuce, and special sauce",
        price: 8.99,
        imageUrl: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=300&fit=crop",
        category: "Burgers"
    ))
    .padding()
}
