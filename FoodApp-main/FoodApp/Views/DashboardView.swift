import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @StateObject private var cartViewModel = CartViewModel()
    
    var body: some View {
        VStack {
            Picker("Category", selection: $viewModel.selectedCategory) {
                ForEach(viewModel.categories, id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            if viewModel.isLoading {
                ProgressView()
            } else if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 20) {
                        ForEach(viewModel.filteredItems) { item in
                            FoodItemView(item: item) {
                                cartViewModel.addToCart(item: item)
                            }
                        }
                    }
                    .padding()
                }
            }
            
            Spacer()
            
            NavigationLink {
                CartView()
                    .environmentObject(cartViewModel)
            } label: {
                Text("Cart (\(cartViewModel.cartItems.count))")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .navigationTitle("Menu")
    }
}

struct FoodItemView: View {
    let item: FoodItem
    let onAddToCart: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(item.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 120)
                .clipped()
                .cornerRadius(8)
            
            Text(item.name)
                .font(.headline)
            
            Text(item.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Text("$\(item.price, specifier: "%.2f")")
                    .font(.headline)
                
                Spacer()
                
                Button(action: onAddToCart) {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
