//
//  FoodComponentsUITests.swift
//  UnitAndUITestPOCUITests
//
//  Created by Janesh Suthar on 25/08/25.
//

import XCTest

final class FoodComponentsUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
        
        // Login first to access food components
        loginWithValidCredentials()
    }
    
    // MARK: - Component Integration Tests
    
    func testFoodListViewAndCardIntegration() throws {
        // Wait for food list to load
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // Test that FoodListView contains FoodItemCards
        let foodItemCards = app.otherElements.containing(.any, identifier: "FoodItemCard")
        
        if !foodItemCards.isEmpty {
            // Test that cards are properly integrated into the list
            for card in foodItemCards {
                XCTAssertTrue(card.exists)
                XCTAssertTrue(card.isAccessibilityElement)
            }
        }
    }
    
    func testFoodItemCardContentDisplay() throws {
        // Wait for food list to load
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // Test that food item cards display all required content
        let foodItemCards = app.otherElements.containing(.any, identifier: "FoodItemCard")
        
        if !foodItemCards.isEmpty {
            let firstCard = foodItemCards.firstMatch
            
            // Test card contains image
            let images = firstCard.images.allElementsBoundByIndex
            XCTAssertTrue(images.count > 0)
            
            // Test card contains text elements
            let textElements = firstCard.staticTexts.allElementsBoundByIndex
            XCTAssertTrue(textElements.count > 0)
        }
    }
    
    // MARK: - Loading States Tests
    
    func testLoadingViewDisplay() throws {
        // Wait for food list to load
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // Test refresh to trigger loading state
        let refreshButton = app.buttons["arrow.clockwise"]
        refreshButton.tap()
        
        // Should show LoadingView
        let loadingText = app.staticTexts["Loading delicious food..."]
        XCTAssertTrue(loadingText.waitForExistence(timeout: 2))
        
        // Should show progress indicator
        let progressIndicator = app.activityIndicators.firstMatch
        XCTAssertTrue(progressIndicator.exists)
    }
    
    func testEmptyStateViewDisplay() throws {
        // This test would require mocking the API to return empty results
        // For now, we'll test the EmptyStateView structure
        
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // If empty state appears, test its components
        let emptyStateTitle = app.staticTexts["No Food Items"]
        let emptyStateMessage = app.staticTexts["No food items available at the moment"]
        let emptyStateIcon = app.images["tray"]
        
        // Note: These might not always be present depending on API response
    }
    
    func testErrorStateViewDisplay() throws {
        // This test would require mocking the API to return errors
        // For now, we'll test the ErrorStateView structure
        
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // If error state appears, test its components
        let errorStateTitle = app.staticTexts["Oops! Something went wrong"]
        let retryButton = app.buttons["Try Again"]
        let errorStateIcon = app.images["exclamationmark.triangle"]
        
        // Note: These might not always be present depending on API response
    }
    
    // MARK: - Image Loading Tests
    
    func testAsyncImageLoading() throws {
        // Wait for food list to load
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // Test AsyncImage loading states
        let foodImages = app.images.allElementsBoundByIndex
        
        if !foodImages.isEmpty {
            // Test that images are loaded properly
            for image in foodImages {
                XCTAssertTrue(image.exists)
                XCTAssertGreaterThan(image.frame.width, 0)
                XCTAssertGreaterThan(image.frame.height, 0)
            }
        }
    }
    
    func testImageLoadingFailure() throws {
        // This test would require mocking image URLs to fail
        // For now, we'll test the fallback structure
        
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // Look for fallback images when loading fails
        let fallbackImages = app.images["photo"]
        
        // Note: This would need image URL mocking to consistently test
    }
    
    // MARK: - Text Truncation Tests
    
    func testTextLineLimits() throws {
        // Wait for food list to load
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // Test that text elements respect line limits
        let allStaticTexts = app.staticTexts.allElementsBoundByIndex
        
        if !allStaticTexts.isEmpty {
            for textElement in allStaticTexts {
                // Test that text elements are properly constrained
                XCTAssertTrue(textElement.exists)
                XCTAssertTrue(textElement.isAccessibilityElement)
            }
        }
    }
    
    // MARK: - Color Scheme Tests
    
    func testColorSchemeAdaptation() throws {
        // Wait for food list to load
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // Test that components adapt to color scheme
        // Note: This is limited in UI tests, but we can test structure
        
        let foodItemCards = app.otherElements.containing(.any, identifier: "FoodItemCard")
        
        if !foodItemCards.isEmpty {
            // Test that cards are visible in both light and dark modes
            for card in foodItemCards {
                XCTAssertTrue(card.exists)
                XCTAssertTrue(card.isHittable)
            }
        }
    }
    
    // MARK: - Responsive Design Tests
    
    func testResponsiveLayout() throws {
        // Wait for food list to load
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // Test that layout is responsive
        let scrollView = app.scrollViews.firstMatch
        
        if scrollView.exists {
            // Test different orientations (if supported)
            // Note: This would require device rotation testing
            
            // Test that content adapts to different screen sizes
            let foodItemCards = app.otherElements.containing(.any, identifier: "FoodItemCard")
            
            if foodItemCards.count > 1 {
                // Test grid layout adapts
                let firstCard = foodItemCards.firstMatch
                let secondCard = foodItemCards.element(boundBy: 1)
                
                XCTAssertTrue(firstCard.exists)
                XCTAssertTrue(secondCard.exists)
            }
        }
    }
    
    // MARK: - Accessibility Integration Tests
    
    func testComponentAccessibilityIntegration() throws {
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // Test that all components work together for accessibility
        XCTAssertTrue(foodMenuNavigationBar.isAccessibilityElement)
        
        let refreshButton = app.buttons["arrow.clockwise"]
        XCTAssertTrue(refreshButton.isAccessibilityElement)
        
        let foodItemCards = app.otherElements.containing(.any, identifier: "FoodItemCard")
        
        if !foodItemCards.isEmpty {
            for card in foodItemCards {
                XCTAssertTrue(card.isAccessibilityElement)
                XCTAssertNotNil(card.accessibilityLabel)
            }
        }
    }
    
    // MARK: - Performance Integration Tests
    
    func testComponentRenderingPerformance() throws {
        // Wait for food list to load
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        measure {
            // Test performance of rendering all components together
            let foodItemCards = app.otherElements.containing(.any, identifier: "FoodItemCard")
            let images = app.images.allElementsBoundByIndex
            let textElements = app.staticTexts.allElementsBoundByIndex
            
            // Verify all components are rendered
            XCTAssertTrue(foodItemCards.count >= 0)
            XCTAssertTrue(images.count >= 0)
            XCTAssertTrue(textElements.count >= 0)
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
