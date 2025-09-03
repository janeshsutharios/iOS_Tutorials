import Combine

protocol CartServiceProtocol {
    var itemsPublisher: Published<[CartItem]>.Publisher { get }
    func addItem(_ item: CartItem)
    func updateQuantity(for item: CartItem, quantity: Int)
    func getItem(withID id: String) -> CartItem?
}