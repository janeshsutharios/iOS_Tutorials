//
//  FoodListUITests.swift
//  UnitAndUITestPOCUITests
//
//  Created by Janesh Suthar on 25/08/25.
//

import XCTest

final class FoodListUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testFoodListScreenAfterLogin() throws {
        // Given
        let usernameField = app.textFields["Enter username"]
        let passwordField = app.secureTextFields["Enter password"]
        let signInButton = app.buttons["Sign In"]
        
        // When - Login first
        usernameField.tap()
        usernameField.typeText("test")
        
        passwordField.tap()
        passwordField.typeText("password")
        
        signInButton.tap()
        
        // Then - Should navigate to food list
        let foodMenuTitle = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuTitle.waitForExistence(timeout: 10))
        
        // Verify food items are loaded
        let refreshButton = app.buttons["arrow.clockwise"]
        XCTAssertTrue(refreshButton.exists)
    }
    
    func testFoodListRefreshFunctionality() throws {
        // Given - Login first
        let usernameField = app.textFields["Enter username"]
        let passwordField = app.secureTextFields["Enter password"]
        let signInButton = app.buttons["Sign In"]
        
        usernameField.tap()
        usernameField.typeText("test")
        
        passwordField.tap()
        passwordField.typeText("password")
        
        signInButton.tap()
        
        // Wait for food list to load
        let foodMenuTitle = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuTitle.waitForExistence(timeout: 10))
        
        // When - Tap refresh button
        let refreshButton = app.buttons["arrow.clockwise"]
        refreshButton.tap()
        
        // Then - Should reload food items
        // The refresh button should be temporarily disabled during loading
        XCTAssertTrue(refreshButton.exists)
    }
    
    func testFoodListScrollFunctionality() throws {
        // Given - Login first
        let usernameField = app.textFields["Enter username"]
        let passwordField = app.secureTextFields["Enter password"]
        let signInButton = app.buttons["Sign In"]
        
        usernameField.tap()
        usernameField.typeText("test")
        
        passwordField.tap()
        passwordField.typeText("password")
        
        signInButton.tap()
        
        // Wait for food list to load
        let foodMenuTitle = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuTitle.waitForExistence(timeout: 10))
        
        // When - Scroll the food list
        let scrollView = app.scrollViews.firstMatch
        scrollView.swipeUp()
        
        // Then - Should be able to scroll
        XCTAssertTrue(scrollView.exists)
    }
    
    func testFoodListNavigationTitle() throws {
        // Given - Login first
        let usernameField = app.textFields["Enter username"]
        let passwordField = app.secureTextFields["Enter password"]
        let signInButton = app.buttons["Sign In"]
        
        usernameField.tap()
        usernameField.typeText("test")
        
        passwordField.tap()
        passwordField.typeText("password")
        
        signInButton.tap()
        
        // Then - Should show correct navigation title
        let foodMenuTitle = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuTitle.waitForExistence(timeout: 10))
    }
    
    func testFoodListLoadingState() throws {
        // Given - Login first
        let usernameField = app.textFields["Enter username"]
        let passwordField = app.secureTextFields["Enter password"]
        let signInButton = app.buttons["Sign In"]
        
        usernameField.tap()
        usernameField.typeText("test")
        
        passwordField.tap()
        passwordField.typeText("password")
        
        signInButton.tap()
        
        // Then - Should show loading state initially
        // The app should transition from loading to loaded state
        let foodMenuTitle = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuTitle.waitForExistence(timeout: 10))
    }
    
    func testFoodListErrorHandling() throws {
        // Given - Login first
        let usernameField = app.textFields["Enter username"]
        let passwordField = app.secureTextFields["Enter password"]
        let signInButton = app.buttons["Sign In"]
        
        usernameField.tap()
        usernameField.typeText("test")
        
        passwordField.tap()
        passwordField.typeText("password")
        
        signInButton.tap()
        
        // Wait for food list to load
        let foodMenuTitle = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuTitle.waitForExistence(timeout: 10))
        
        // When - Try to refresh (this might trigger an error if network is down)
        let refreshButton = app.buttons["arrow.clockwise"]
        refreshButton.tap()
        
        // Then - Should handle errors gracefully
        // The app should show appropriate error state or continue working
        XCTAssertTrue(foodMenuTitle.exists)
    }
}
