import Combine
import Foundation

class CartViewModel {
    private let cartService: CartServiceProtocol
    @Published var items: [CartItem] = []
    private var cancellables = Set<AnyCancellable>()

    init(cartService: CartServiceProtocol) {
        self.cartService = cartService

        cartService.itemsPublisher
            .receive(on: RunLoop.main)
            .assign(to: \CartViewModel.items, on: self)
            .store(in: &cancellables)
    }
}
