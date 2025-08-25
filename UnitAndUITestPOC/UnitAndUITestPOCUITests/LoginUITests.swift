//
//  LoginUITests.swift
//  UnitAndUITestPOCUITests
//
//  Created by Janesh Suthar on 25/08/25.
//

import XCTest

final class LoginUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testLoginScreenElementsExist() throws {
        // Given & When & Then
        // Check that all login screen elements are present
        XCTAssertTrue(app.staticTexts["Food App"].exists)
        XCTAssertTrue(app.staticTexts["Sign in to explore delicious food"].exists)
        XCTAssertTrue(app.staticTexts["Username"].exists)
        XCTAssertTrue(app.staticTexts["Password"].exists)
        XCTAssertTrue(app.textFields["Enter username"].exists)
        XCTAssertTrue(app.secureTextFields["Enter password"].exists)
        XCTAssertTrue(app.buttons["Sign In"].exists)
        XCTAssertTrue(app.staticTexts["Demo Credentials"].exists)
    }
    
    func testLoginWithEmptyCredentials() throws {
        // Given
        let signInButton = app.buttons["Sign In"]
        
        // When
        signInButton.tap()
        
        // Then
        // Should show error message for empty credentials
        let errorMessage = app.staticTexts["Please enter both username and password"]
        XCTAssertTrue(errorMessage.exists)
    }
    
    func testLoginWithValidCredentials() throws {
        // Given
        let usernameField = app.textFields["Enter username"]
        let passwordField = app.secureTextFields["Enter password"]
        let signInButton = app.buttons["Sign In"]
        
        // When
        usernameField.tap()
        usernameField.typeText("test")
        
        passwordField.tap()
        passwordField.typeText("password")
        
        signInButton.tap()
        
        // Then
        // Should navigate to food list screen
        let foodMenuTitle = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuTitle.waitForExistence(timeout: 10))
    }
    
    func testPasswordVisibilityToggle() throws {
        // Given
        let passwordField = app.secureTextFields["Enter password"]
        let eyeButton = app.buttons.matching(identifier: "eye.fill").firstMatch
        
        // When
        passwordField.tap()
        passwordField.typeText("testpassword")
        
        // Then - Password should be hidden initially
        XCTAssertTrue(passwordField.exists)
        
        // When - Toggle password visibility
        eyeButton.tap()
        
        // Then - Password should be visible
        let visiblePasswordField = app.textFields["Enter password"]
        XCTAssertTrue(visiblePasswordField.exists)
        
        // When - Toggle back
        eyeButton.tap()
        
        // Then - Password should be hidden again
        XCTAssertTrue(passwordField.exists)
    }
    
    func testLoginButtonDisabledDuringLoading() throws {
        // Given
        let usernameField = app.textFields["Enter username"]
        let passwordField = app.secureTextFields["Enter password"]
        let signInButton = app.buttons["Sign In"]
        
        // When
        usernameField.tap()
        usernameField.typeText("test")
        
        passwordField.tap()
        passwordField.typeText("password")
        
        signInButton.tap()
        
        // Then
        // Button should be disabled during loading
        XCTAssertFalse(signInButton.isEnabled)
    }
    
    func testLoginFormValidation() throws {
        // Given
        let usernameField = app.textFields["Enter username"]
        let passwordField = app.secureTextFields["Enter password"]
        let signInButton = app.buttons["Sign In"]
        
        // When - Only username
        usernameField.tap()
        usernameField.typeText("test")
        signInButton.tap()
        
        // Then
        let errorMessage = app.staticTexts["Please enter both username and password"]
        XCTAssertTrue(errorMessage.exists)
        
        // When - Clear and try only password
        usernameField.tap()
        usernameField.doubleTap()
        usernameField.typeText("")
        
        passwordField.tap()
        passwordField.typeText("password")
        signInButton.tap()
        
        // Then
        XCTAssertTrue(errorMessage.exists)
    }
}
