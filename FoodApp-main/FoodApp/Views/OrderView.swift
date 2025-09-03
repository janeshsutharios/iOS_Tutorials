import SwiftUI

struct OrderView: View {
    @EnvironmentObject private var cartViewModel: CartViewModel
    @StateObject private var viewModel = OrderViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                } else if viewModel.isOrderPlaced {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Order Placed Successfully!")
                            .font(.title)
                        
                        Text("Your order total is $\(cartViewModel.totalPrice, specifier: "%.2f")")
                            .font(.headline)
                        
                        Button("Done") {
                            dismiss()
                            cartViewModel.cartItems.removeAll()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(cartViewModel.cartItems) { item in
                            HStack {
                                Image(item.imageName)
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                                
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                    Text("$\(item.price, specifier: "%.2f")")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        HStack {
                            Text("Total:")
                                .font(.headline)
                            Spacer()
                            Text("$\(cartViewModel.totalPrice, specifier: "%.2f")")
                                .font(.headline)
                        }
                    }
                    .listStyle(.plain)
                    
                    Button("Confirm Order") {
                        viewModel.placeOrder(items: cartViewModel.cartItems)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Place Order")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
