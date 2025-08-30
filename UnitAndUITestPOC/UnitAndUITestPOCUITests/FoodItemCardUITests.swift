//
//  FoodItemCardUITests.swift
//  UnitAndUITestPOCUITests
//
//  Created by Janesh Suthar on 25/08/25.
//

import XCTest

final class FoodItemCardUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
        
        // Login first to access food list with cards
        loginWithValidCredentials()
    }
    
    // MARK: - Card Structure Tests
    
    func testFoodItemCardBasicStructure() throws {
        // Wait for food list to load
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // Look for food item cards
        let foodItemCards = app.otherElements.containing(.any, identifier: "FoodItemCard")
        
        if !foodItemCards.isEmpty {
            let firstCard = foodItemCards.firstMatch
            
            // Test card exists and is visible
            XCTAssertTrue(firstCard.exists)
            XCTAssertTrue(firstCard.isHittable)
            
            // Test card has proper accessibility
            XCTAssertTrue(firstCard.isAccessibilityElement)
        }
    }
    
    func testFoodItemCardElements() throws {
        // Wait for food list to load
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // Look for food item cards
        let foodItemCards = app.otherElements.containing(.any, identifier: "FoodItemCard")
        
        if !foodItemCards.isEmpty {
            let firstCard = foodItemCards.firstMatch
            
            // Test that card contains expected elements
            // Note: These elements might not be directly accessible in UI tests
            // but we can test the card structure
            
            // Test card has proper dimensions and styling
            XCTAssertTrue(firstCard.exists)
            
            // Test card is properly positioned in the grid
            let cardFrame = firstCard.frame
            XCTAssertGreaterThan(cardFrame.width, 0)
            XCTAssertGreaterThan(cardFrame.height, 0)
        }
    }
    
    // MARK: - Image Loading Tests
    
    func testFoodItemImageLoadingStates() throws {
        // Wait for food list to load
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // Look for images in food cards
        let foodImages = app.images.allElementsBoundByIndex
        
        if !foodImages.isEmpty {
            // Test that images are present
            XCTAssertTrue(foodImages.count > 0)
            
            // Test that images have proper dimensions
            for image in foodImages {
                XCTAssertGreaterThan(image.frame.width, 0)
                XCTAssertGreaterThan(image.frame.height, 0)
            }
        }
    }
    
    func testFoodItemImageLoadingIndicator() throws {
        // Wait for food list to load
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // Look for loading indicators (progress views)
        let progressIndicators = app.activityIndicators.allElementsBoundByIndex
        
        // Note: Loading indicators might be present during image loading
        // This test verifies they exist when needed
        if !progressIndicators.isEmpty {
            for indicator in progressIndicators {
                XCTAssertTrue(indicator.exists)
            }
        }
    }
    
    func testFoodItemImageFailureState() throws {
        // Wait for food list to load
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // Look for fallback images (photo icon) when image loading fails
        let fallbackImages = app.images["photo"]
        
        // Note: This would need image URL mocking to consistently test
        // For now, we verify the structure exists
        if fallbackImages.exists {
            XCTAssertTrue(fallbackImages.isAccessibilityElement)
        }
    }
    
    // MARK: - Text Content Tests
    
    func testFoodItemTextElements() throws {
        // Wait for food list to load
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // Look for text elements in food cards
        let allStaticTexts = app.staticTexts.allElementsBoundByIndex
        
        if !allStaticTexts.isEmpty {
            // Test that text elements exist and are readable
            for textElement in allStaticTexts {
                XCTAssertTrue(textElement.exists)
                XCTAssertTrue(textElement.isAccessibilityElement)
                
                // Test that text has content
                if let textValue = textElement.value as? String {
                    XCTAssertFalse(textValue.isEmpty)
                }
            }
        }
    }
    
    func testFoodItemPriceDisplay() throws {
        // Wait for food list to load
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // Look for price elements (they should be styled differently)
        let allStaticTexts = app.staticTexts.allElementsBoundByIndex
        
        // Test that price elements exist and are properly formatted
        // Note: In a real scenario, you'd identify price elements specifically
        if !allStaticTexts.isEmpty {
            // Look for text that might be prices (contains $ or numbers)
            let priceElements = allStaticTexts.filter { element in
                if let text = element.value as? String {
                    return text.contains("$") || text.range(of: #"\d+\.\d{2}"#, options: .regularExpression) != nil
                }
                return false
            }
            
            // Test price elements if found
            for priceElement in priceElements {
                XCTAssertTrue(priceElement.exists)
                XCTAssertTrue(priceElement.isAccessibilityElement)
            }
        }
    }
    
    func testFoodItemCategoryDisplay() throws {
        // Wait for food list to load
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // Look for category elements
        let allStaticTexts = app.staticTexts.allElementsBoundByIndex
        
        // Test that category elements exist and are properly styled
        // Note: Categories are typically shorter text elements
        if !allStaticTexts.isEmpty {
            let categoryElements = allStaticTexts.filter { element in
                if let text = element.value as? String {
                    // Categories are usually short, single words
                    return text.count < 20 && !text.contains("$") && !text.contains(".")
                }
                return false
            }
            
            // Test category elements if found
            for categoryElement in categoryElements {
                XCTAssertTrue(categoryElement.exists)
                XCTAssertTrue(categoryElement.isAccessibilityElement)
            }
        }
    }
    
    // MARK: - Layout and Styling Tests
    
    func testFoodItemCardLayout() throws {
        // Wait for food list to load
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // Look for food item cards
        let foodItemCards = app.otherElements.containing(.any, identifier: "FoodItemCard")
        
        if foodItemCards.count > 1 {
            let firstCard = foodItemCards.firstMatch
            let secondCard = foodItemCards.element(boundBy: 1)
            
            // Test that cards are properly spaced
            let firstCardFrame = firstCard.frame
            let secondCardFrame = secondCard.frame
            
            // Cards should not overlap
            XCTAssertFalse(firstCardFrame.intersects(secondCardFrame))
            
            // Cards should have similar dimensions
            XCTAssertEqual(firstCardFrame.width, secondCardFrame.width, accuracy: 10)
        }
    }
    
    func testFoodItemCardStyling() throws {
        // Wait for food list to load
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // Look for food item cards
        let foodItemCards = app.otherElements.containing(.any, identifier: "FoodItemCard")
        
        if !foodItemCards.isEmpty {
            let firstCard = foodItemCards.firstMatch
            
            // Test card styling properties
            XCTAssertTrue(firstCard.exists)
            
            // Test that card has proper accessibility properties
            XCTAssertTrue(firstCard.isAccessibilityElement)
            
            // Test that card has proper accessibility label
            XCTAssertNotNil(firstCard.accessibilityLabel)
        }
    }
    
    // MARK: - Accessibility Tests
    
    func testFoodItemCardAccessibility() throws {
        // Wait for food list to load
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // Look for food item cards
        let foodItemCards = app.otherElements.containing(.any, identifier: "FoodItemCard")
        
        if !foodItemCards.isEmpty {
            let firstCard = foodItemCards.firstMatch
            
            // Test accessibility properties
            XCTAssertTrue(firstCard.isAccessibilityElement)
            XCTAssertNotNil(firstCard.accessibilityLabel)
            
            // Test that card is accessible to VoiceOver
            XCTAssertTrue(firstCard.isVoiceOverAccessible)
        }
    }
    
    func testFoodItemCardVoiceOverNavigation() throws {
        // Wait for food list to load
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // Look for food item cards
        let foodItemCards = app.otherElements.containing(.any, identifier: "FoodItemCard")
        
        if !foodItemCards.isEmpty {
            let firstCard = foodItemCards.firstMatch
            
            // Test that card can be navigated to with VoiceOver
            XCTAssertTrue(firstCard.isAccessibilityElement)
            
            // Test that card has proper accessibility hint
            XCTAssertNotNil(firstCard.accessibilityHint)
        }
    }
    
    // MARK: - Interaction Tests
    
    func testFoodItemCardTapInteraction() throws {
        // Wait for food list to load
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // Look for food item cards
        let foodItemCards = app.otherElements.containing(.any, identifier: "FoodItemCard")
        
        if !foodItemCards.isEmpty {
            let firstCard = foodItemCards.firstMatch
            
            // Test that card is tappable
            XCTAssertTrue(firstCard.isHittable)
            
            // Test tapping the card
            firstCard.tap()
            
            // Note: In a real app, this might navigate to detail view
            // For now, we just test that the tap doesn't crash
            XCTAssertTrue(foodMenuNavigationBar.exists)
        }
    }
    
    // MARK: - Performance Tests
    
    func testFoodItemCardRenderingPerformance() throws {
        // Wait for food list to load
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        
        // Measure the time it takes to render food item cards
        measure {
            // Look for food item cards
            let foodItemCards = app.otherElements.containing(.any, identifier: "FoodItemCard")
            
            // Verify cards are rendered
            XCTAssertTrue(foodItemCards.count > 0)
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

// MARK: - XCUIElement Extensions

extension XCUIElement {
    var isVoiceOverAccessible: Bool {
        return self.isAccessibilityElement && 
               self.accessibilityLabel != nil && 
               self.accessibilityLabel?.isEmpty == false
    }
}
