//
//  ScalablePackageNavigationTests.swift
//  ScalablePackageNavigationTests
//
//  Created by Janesh Suthar on 08/08/25.
//

import XCTest
@testable import AppRouter

final class AppRouterTests: XCTestCase {
    var router: AppRouter!
    
    override func setUp() {
        super.setUp()
        router = AppRouter()
    }
    
    override func tearDown() {
        router = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertTrue(router.path.isEmpty, "Navigation path should be empty initially")
        XCTAssertTrue(router.cartItems.isEmpty, "Cart items should be empty initially")
    }
    
    // MARK: - Navigation Tests
    
    func testNavigationPath() {
        router.path.append(.cart)
        XCTAssertEqual(router.path.count, 1, "Path should contain one route")
        XCTAssertEqual(router.path.first, .cart, "First route should be cart")
        
        router.path.append(.summary)
        XCTAssertEqual(router.path.count, 2, "Path should contain two routes")
        XCTAssertEqual(router.path.last, .summary, "Last route should be summary")
    }
    
    func testClearNavigationPath() {
        router.path.append(.cart)
        router.path.append(.summary)
        XCTAssertEqual(router.path.count, 2, "Path should contain two routes")
        
        router.path = []
        XCTAssertTrue(router.path.isEmpty, "Path should be empty after clearing")
    }
    
    // MARK: - Cart Items Tests
    
    func testAddCartItem() {
        router.cartItems.append("Pizza")
        XCTAssertEqual(router.cartItems.count, 1, "Cart should contain one item")
        XCTAssertEqual(router.cartItems.first, "Pizza", "First item should be Pizza")
    }
    
    func testAddMultipleCartItems() {
        router.cartItems.append("Pizza")
        router.cartItems.append("Burger")
        router.cartItems.append("Salad")
        
        XCTAssertEqual(router.cartItems.count, 3, "Cart should contain three items")
        XCTAssertEqual(router.cartItems, ["Pizza", "Burger", "Salad"], "Items should match expected order")
    }
    
    func testRemoveCartItems() {
        router.cartItems.append("Pizza")
        router.cartItems.append("Burger")
        XCTAssertEqual(router.cartItems.count, 2, "Cart should contain two items")
        
        router.cartItems.removeAll()
        XCTAssertTrue(router.cartItems.isEmpty, "Cart should be empty after removing all items")
    }
    
    func testRemoveSpecificCartItem() {
        router.cartItems.append("Pizza")
        router.cartItems.append("Burger")
        router.cartItems.append("Salad")
        
        router.cartItems.remove(at: 1)
        XCTAssertEqual(router.cartItems.count, 2, "Cart should contain two items after removal")
        XCTAssertEqual(router.cartItems, ["Pizza", "Salad"], "Items should match expected after removal")
    }
    
    // MARK: - Integration Tests
    
    func testCompleteOrderFlow() {
        // Add items to cart
        router.cartItems.append("Pizza")
        router.cartItems.append("Burger")
        XCTAssertEqual(router.cartItems.count, 2, "Cart should contain two items")
        
        // Navigate to cart
        router.path.append(.cart)
        XCTAssertEqual(router.path.count, 1, "Path should contain one route")
        XCTAssertEqual(router.path.first, .cart, "First route should be cart")
        
        // Navigate to summary
        router.path.append(.summary)
        XCTAssertEqual(router.path.count, 2, "Path should contain two routes")
        XCTAssertEqual(router.path.last, .summary, "Last route should be summary")
        
        // Complete order (clear everything)
        router.path = []
        router.cartItems.removeAll()
        XCTAssertTrue(router.path.isEmpty, "Path should be empty after completing order")
        XCTAssertTrue(router.cartItems.isEmpty, "Cart should be empty after completing order")
    }
    
    func testNavigationBackToDashboard() {
        router.path.append(.cart)
        router.path.append(.summary)
        XCTAssertEqual(router.path.count, 2, "Path should contain two routes")
        
        // Navigate back to dashboard
        router.path.append(.dashboard)
        XCTAssertEqual(router.path.count, 3, "Path should contain three routes")
        XCTAssertEqual(router.path.last, .dashboard, "Last route should be dashboard")
    }
    
    // MARK: - Edge Cases
    
    func testEmptyCartNavigation() {
        // Should be able to navigate to cart even with empty cart
        router.path.append(.cart)
        XCTAssertEqual(router.path.first, .cart, "Should be able to navigate to cart")
    }
    
    func testDuplicateItems() {
        router.cartItems.append("Pizza")
        router.cartItems.append("Pizza")
        XCTAssertEqual(router.cartItems.count, 2, "Should allow duplicate items")
        XCTAssertEqual(router.cartItems, ["Pizza", "Pizza"], "Should contain duplicate items")
    }
    
    func testEmptyStringItem() {
        router.cartItems.append("")
        XCTAssertEqual(router.cartItems.count, 1, "Should allow empty string items")
        XCTAssertEqual(router.cartItems.first, "", "Should contain empty string")
    }
    
    // MARK: - Performance Tests
    
    func testLargeCartPerformance() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Add many items
        for i in 1...1000 {
            router.cartItems.append("Item \(i)")
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let executionTime = endTime - startTime
        
        XCTAssertEqual(router.cartItems.count, 1000, "Should contain 1000 items")
        XCTAssertLessThan(executionTime, 0.1, "Adding 1000 items should take less than 0.1 seconds")
    }
    
    func testLargeNavigationPathPerformance() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Add many navigation routes
        for _ in 1...100 {
            router.path.append(.cart)
            router.path.append(.summary)
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let executionTime = endTime - startTime
        
        XCTAssertEqual(router.path.count, 200, "Should contain 200 routes")
        XCTAssertLessThan(executionTime, 0.1, "Adding 200 routes should take less than 0.1 seconds")
    }
}
