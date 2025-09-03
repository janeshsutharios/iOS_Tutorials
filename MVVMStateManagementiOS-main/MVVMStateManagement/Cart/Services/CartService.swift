import Combine
import UIKit

final class CartService: CartServiceProtocol {
    @Published private(set) var items: [CartItem] = []
    private let queue = DispatchQueue(label: "cart.queue", attributes: .concurrent)

    var itemsPublisher: Published<[CartItem]>.Publisher { $items }

    func addItem(_ item: CartItem) {
        queue.async(flags: .barrier) {
            if !self.items.contains(where: { $0.id == item.id }) {
                DispatchQueue.main.async {
                    self.items.append(item)
                }
            }
        }
    }

    func updateQuantity(for item: CartItem, quantity: Int) {
        queue.async(flags: .barrier) {
            DispatchQueue.main.async {
                item.quantity = quantity
            }
        }
    }

    func getItem(withID id: String) -> CartItem? {
        return items.first(where: { $0.id == id })
    }
}
