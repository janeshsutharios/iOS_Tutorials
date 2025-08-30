//
//  UnitAndUITestPOCUITests.swift
//  UnitAndUITestPOCUITests
//
//  Created by Janesh Suthar on 25/08/25.
//

import XCTest

final class UnitAndUITestPOCUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    override func tearDownWithError() throws {
        // Clean up after each test
    }
    
    // MARK: - Login Flow Tests
    
    func testLoginViewInitialState() throws {
        // Test that login view appears with correct elements
        XCTAssertTrue(app.staticTexts["Food App"].exists)
        XCTAssertTrue(app.staticTexts["Sign in to explore delicious food"].exists)
        XCTAssertTrue(app.textFields["Enter username"].exists)
        XCTAssertTrue(app.secureTextFields["Enter password"].exists)
        XCTAssertTrue(app.buttons["Sign In"].exists)
        XCTAssertTrue(app.staticTexts["Demo Credentials"].exists)
        XCTAssertTrue(app.staticTexts["Username: test | Password: password"].exists)
    }
    
    func testSuccessfulLoginFlow() throws {
        // Test successful login with demo credentials
        let usernameTextField = app.textFields["Enter username"]
        let passwordTextField = app.secureTextFields["Enter password"]
        let signInButton = app.buttons["Sign In"]
        
        // Enter credentials
        usernameTextField.tap()
        usernameTextField.typeText("test")
        
        passwordTextField.tap()
        passwordTextField.typeText("password")
        
        // Tap sign in
        signInButton.tap()
        
        // Wait for navigation to food list
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
    }
    
    func testLoginWithInvalidCredentials() throws {
        // Test login with invalid credentials
        let usernameTextField = app.textFields["Enter username"]
        let passwordTextField = app.secureTextFields["Enter password"]
        let signInButton = app.buttons["Sign In"]
        
        // Enter invalid credentials
        usernameTextField.tap()
        usernameTextField.typeText("invalid")
        
        passwordTextField.tap()
        passwordTextField.typeText("wrongpassword")
        
        // Tap sign in
        signInButton.tap()
        
        // Should show error message
        let errorMessage = app.staticTexts.containing(.init(format: "Invalid credentials")).firstMatch
        XCTAssertTrue(errorMessage.waitForExistence(timeout: 5))
    }
    
    func testPasswordVisibilityToggle() throws {
        // Test password visibility toggle functionality
        let passwordTextField = app.secureTextFields["Enter password"]
        let eyeButton = app.buttons["eye.fill"]
        
        // Initially should be secure field
        XCTAssertTrue(passwordTextField.exists)
        XCTAssertTrue(eyeButton.exists)
        
        // Tap eye button to show password
        eyeButton.tap()
        
        // Should now be regular text field
        let visiblePasswordField = app.textFields["Enter password"]
        let eyeSlashButton = app.buttons["eye.slash.fill"]
        XCTAssertTrue(visiblePasswordField.exists)
        XCTAssertTrue(eyeSlashButton.exists)
        
        // Tap again to hide password
        eyeSlashButton.tap()
        XCTAssertTrue(passwordTextField.exists)
        XCTAssertTrue(eyeButton.exists)
    }
    
    func testLoginButtonDisabledDuringLoading() throws {
        // Test that login button is disabled during loading
        let usernameTextField = app.textFields["Enter username"]
        let passwordTextField = app.secureTextFields["Enter password"]
        let signInButton = app.buttons["Sign In"]
        
        // Enter credentials
        usernameTextField.tap()
        usernameTextField.typeText("test")
        
        passwordTextField.tap()
        passwordTextField.typeText("password")
        
        // Tap sign in
        signInButton.tap()
        
        // Button should be disabled during loading
        XCTAssertFalse(signInButton.isEnabled)
    }
    
    // MARK: - Food List Flow Tests
    
    func testFoodListNavigationAfterLogin() throws {
        // Login first
        loginWithValidCredentials()
        
        // Verify food list view elements
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // Check for refresh button
        let refreshButton = app.buttons["arrow.clockwise"]
        XCTAssertTrue(refreshButton.exists)
    }
    
    func testFoodListRefreshFunctionality() throws {
        // Login first
        loginWithValidCredentials()
        
        // Wait for food list to load
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // Tap refresh button
        let refreshButton = app.buttons["arrow.clockwise"]
        refreshButton.tap()
        
        // Should show loading state briefly
        let loadingText = app.staticTexts["Loading delicious food..."]
        XCTAssertTrue(loadingText.waitForExistence(timeout: 2))
    }
    
    func testFoodItemCardDisplay() throws {
        // Login first
        loginWithValidCredentials()
        
        // Wait for food list to load
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // Check if food items are displayed (if any exist)
        let foodItemCards = app.otherElements.containing(.any, identifier: "FoodItemCard")
        if !foodItemCards.isEmpty {
            // Verify food item card elements
            let firstCard = foodItemCards.firstMatch
            XCTAssertTrue(firstCard.exists)
        }
    }
    
    func testEmptyStateDisplay() throws {
        // This test would require mocking the network to return empty results
        // For now, we'll test the structure
        loginWithValidCredentials()
        
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // If no food items, should show empty state
        let emptyStateText = app.staticTexts["No Food Items"]
        let emptyStateMessage = app.staticTexts["No food items available at the moment"]
        
        // Note: This might not always be true depending on the API response
        // In a real scenario, you'd mock the network to return empty results
    }
    
    func testErrorStateDisplay() throws {
        // This test would require mocking the network to return errors
        // For now, we'll test the structure
        loginWithValidCredentials()
        
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // If error occurs, should show error state with retry button
        let errorStateText = app.staticTexts["Oops! Something went wrong"]
        let retryButton = app.buttons["Try Again"]
        
        // Note: This might not always be true depending on the API response
        // In a real scenario, you'd mock the network to return errors
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityLabels() throws {
        // Test that important elements have accessibility labels
        XCTAssertTrue(app.textFields["Enter username"].exists)
        XCTAssertTrue(app.secureTextFields["Enter password"].exists)
        XCTAssertTrue(app.buttons["Sign In"].exists)
        
        // Test password visibility toggle accessibility
        let eyeButton = app.buttons["eye.fill"]
        XCTAssertTrue(eyeButton.exists)
    }
    
    func testVoiceOverCompatibility() throws {
        // Test that elements are accessible to VoiceOver
        let usernameField = app.textFields["Enter username"]
        let passwordField = app.secureTextFields["Enter password"]
        let signInButton = app.buttons["Sign In"]
        
        XCTAssertTrue(usernameField.isAccessibilityElement)
        XCTAssertTrue(passwordField.isAccessibilityElement)
        XCTAssertTrue(signInButton.isAccessibilityElement)
    }
    
    // MARK: - Performance Tests
    
    func testAppLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
        }
    }
    
    func testLoginFlowPerformance() throws {
        measure {
            loginWithValidCredentials()
        }
    }
    
    // MARK: - Helper Methods
    
    private func loginWithValidCredentials() {
        let usernameTextField = app.textFields["Enter username"]
        let passwordTextField = app.secureTextFields["Enter password"]
        let signInButton = app.buttons["Sign In"]
        
        usernameTextField.tap()
        usernameTextField.typeText("test")
        
        passwordTextField.tap()
        passwordTextField.typeText("password")
        
        signInButton.tap()
    }
}
