//
//  FoodListUITests.swift
//  UnitAndUITestPOCUITests
//
//  Created by Janesh Suthar on 25/08/25.
//

import XCTest

final class FoodListUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
        
        // Login first to access food list
        loginWithValidCredentials()
    }
    
    // MARK: - Navigation Tests
    
    func testFoodListNavigationTitle() throws {
        let foodMenuNavigationBar = app.navigationBars["Food Menu"]
        XCTAssertTrue(foodMenuNavigationBar.waitForExistence(timeout: 10))
        XCTAssertTrue(foodMenuNavigationBar.staticTexts["Food M
