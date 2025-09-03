//
//  MVVMStateManagementTests.swift
//  MVVMStateManagementTests
//
//  Created by JANESH SUTHAR on 13/06/25.
//

import XCTest
import Combine
@testable import MVVMStateManagement

final class MVVMStateManagementTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable>!
    var cartService: CartService!
    
    override func setUp() {
        super.setUp()
        cancellables = []
        cartService = CartService()
    }

    override func tearDown() {
        cancellables = nil
        cartService = nil
        super.tearDown()
    }

    func testCartViewModelInitialItems() async throws {
        // Given
        let item = CartItem(id: "1", name: "Product", quantity: 1)
        let viewModel = CartViewModel(cartService: cartService)

        // When
        cartService.addItem(item)

        // Then
        let count = try await withCheckedThrowingContinuation { continuation in
            viewModel.$items
                .dropFirst()// // Ignore the initial value (e.g., [])
                .sink { items in
                // Now only reacts to actual updates
                    if items.count == 1 {
                        continuation.resume(returning: items.count)
                    }
                }
                .store(in: &cancellables)
        }

        XCTAssertEqual(count, 1)
        XCTAssertEqual(viewModel.items.first?.quantity, 1)
    }


    func testQuantityUpdateReflectsInCartService() async throws {
        // Given
        let item = CartItem(id: "1", name: "Product", quantity: 1)
        cartService.addItem(item)

        let detailViewModel = CartDetailViewModel(item: item, cartService: cartService)
        let cartViewModel = CartViewModel(cartService: cartService)

        // When
        let updatedQuantity = try await withTimeout(seconds: 2) {
            try await withCheckedThrowingContinuation { continuation in
                let cancellable = cartViewModel.$items
                    .dropFirst()
                    .sink { items in
                        if let updated = items.first(where: { $0.id == item.id }),
                           updated.quantity == 5 {
                            continuation.resume(returning: updated.quantity)
                        }
                    }

                // Store the cancellable to keep the subscription alive
                self.cancellables.insert(cancellable)

                // Trigger the update
                detailViewModel.updateQuantity(5)
            }
        }

        // Then
        XCTAssertEqual(updatedQuantity, 5)
    }

    func withTimeout<T>(seconds: UInt64, operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }

            group.addTask {
                try await Task.sleep(nanoseconds: seconds * 1_000_000_000)
                throw NSError(domain: "TestTimeout", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test timed out"])
            }

            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }

    func testTwoViewModelsStayInSync() {
        // Given
        let item = CartItem(id: "1", name: "Product", quantity: 2)
        cartService.addItem(item)

        let detailVM = CartDetailViewModel(item: item, cartService: cartService)
        let cartVM = CartViewModel(cartService: cartService)

        let expectation = XCTestExpectation(description: "Quantity sync")

        cartVM.$items
            .dropFirst() // Skip initial value
            .sink { items in
                if let updated = items.first(where: { $0.id == item.id }) {
                    if updated.quantity == 10 {
                        expectation.fulfill()
                    }
                }
            }
            .store(in: &cancellables)

        // When
        detailVM.updateQuantity(10)

        // Then
        wait(for: [expectation], timeout: 2.0)
    }
}
