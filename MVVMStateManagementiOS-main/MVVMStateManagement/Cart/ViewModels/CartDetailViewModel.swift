class CartDetailViewModel {
    let item: CartItem
    private let cartService: CartServiceProtocol

    init(item: CartItem, cartService: CartServiceProtocol) {
        self.item = item
        self.cartService = cartService
    }

    func updateQuantity(_ quantity: Int) {
        cartService.updateQuantity(for: item, quantity: quantity)
    }
}