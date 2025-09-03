import Foundation

class CartItem: Identifiable, ObservableObject {
    let id: String
    let name: String
    @Published var quantity: Int

    init(id: String, name: String, quantity: Int) {
        self.id = id
        self.name = name
        self.quantity = quantity
    }
}