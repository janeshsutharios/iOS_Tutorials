import SwiftUI

struct CartView: View {
    @EnvironmentObject private var cartViewModel: CartViewModel
    @State private var isShowingOrderView = false
    
    var body: some View {
        VStack {
            if cartViewModel.cartItems.isEmpty {
                Text("Your cart is empty")
                    .foregroundColor(.secondary)
                Spacer()
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
                            
                            Spacer()
                        }
                    }
                    .onDelete(perform: cartViewModel.removeFromCart)
                    
                    HStack {
                        Text("Total:")
                            .font(.headline)
                        Spacer()
                        Text("$\(cartViewModel.totalPrice, specifier: "%.2f")")
                            .font(.headline)
                    }
                }
                .listStyle(.plain)
            }
            
            Button(action: { isShowingOrderView = true }) {
                Text("Place Order")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(cartViewModel.cartItems.isEmpty)
            .padding()
        }
        .navigationTitle("Your Cart")
        .sheet(isPresented: $isShowingOrderView) {
            OrderView()
                .environmentObject(cartViewModel)
        }
    }
}
