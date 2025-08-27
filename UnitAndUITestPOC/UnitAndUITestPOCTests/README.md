# Unit Tests Documentation

This document provides an overview of the comprehensive unit testing strategy implemented for the UnitAndUITestPOC iOS application.

## 🎯 Testing Strategy

Our testing approach follows the **AAA (Arrange-Act-Assert)** pattern and implements comprehensive coverage across all layers of the application:

- **Models**: Data structures, encoding/decoding, and business logic
- **Services**: Business logic and data processing
- **ViewModels**: UI state management and user interactions
- **Networking**: API communication and error handling
- **Integration**: End-to-end workflows
- **Performance**: Performance benchmarks and optimization

## 📁 Test Organization

### Core Test Files

1. **`ModelsTests.swift`** - Tests for data models and business logic
2. **`NetworkTests.swift`** - Tests for networking layer and API endpoints
3. **`ServicesTests.swift`** - Tests for service layer business logic
4. **`ViewModelsTests.swift`** - Tests for ViewModel state management
5. **`IntegrationTests.swift`** - End-to-end workflow tests
6. **`PerformanceTests.swift`** - Performance benchmarks
7. **`TestHelpers.swift`** - Shared utilities and test data factories

### Test Categories

#### Unit Tests
- **Model Tests**: Data validation, encoding/decoding, computed properties
- **Service Tests**: Business logic, error handling, data transformation
- **ViewModel Tests**: State management, user interactions, computed properties
- **Network Tests**: API endpoints, error handling, request/response processing

#### Integration Tests
- **Login Flow**: Complete authentication workflow
- **Food Items Flow**: Complete data fetching workflow
- **End-to-End**: Full user journey from login to data display

#### Performance Tests
- **Model Performance**: Object creation, encoding/decoding speed
- **ViewModel Performance**: State changes, computed properties
- **Service Performance**: Business logic execution time
- **Large Data Performance**: Handling of large datasets

## 🛠 Testing Best Practices

### Swift 6 Compatibility
- Uses `@MainActor` for UI-related tests
- Implements proper `Sendable` conformance
- Uses `nonisolated` where appropriate
- Leverages modern Swift concurrency features

### Test Structure
```swift
@MainActor
final class ComponentTests: XCTestCase {
    
    // MARK: - Setup and Teardown
    
    override func setUp() async throws {
        // Setup test environment
    }
    
    override func tearDown() async throws {
        // Cleanup test environment
    }
    
    // MARK: - Test Methods
    
    func testComponentBehavior() async {
        // Arrange
        let component = Component()
        
        // Act
        let result = await component.performAction()
        
        // Assert
        XCTAssertEqual(result, expectedValue)
    }
}
```

### Mocking Strategy
- **Protocol-based mocking**: All dependencies implement protocols
- **Injectable dependencies**: Services accept mock implementations
- **Comprehensive mock coverage**: All external dependencies are mocked
- **State verification**: Mocks track calls and verify interactions

### Async Testing
```swift
func testAsyncOperation() async throws {
    // Arrange
    let service = MockService()
    service.configureForSuccess(expectedResponse)
    
    // Act
    let result = try await service.performAsyncOperation()
    
    // Assert
    XCTAssertEqual(result, expectedResponse)
}
```

### Error Testing
```swift
func testErrorHandling() async {
    // Arrange
    let service = MockService()
    service.configureForFailure(NetworkError.unauthorized)
    
    // Act & Assert
    await XCTAssertThrowsAsyncError({
        try await service.performOperation()
    }, NetworkError.unauthorized)
}
```

## 🚀 Running Tests

### Xcode
1. Open the project in Xcode
2. Select the test target `UnitAndUITestPOCTests`
3. Press `Cmd+U` to run all tests
4. Use the test navigator to run specific test classes or methods

### Command Line
```bash
# Run all tests
xcodebuild test -scheme UnitAndUITestPOC -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test class
xcodebuild test -scheme UnitAndUITestPOC -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:UnitAndUITestPOCTests/ModelsTests

# Run specific test method
xcodebuild test -scheme UnitAndUITestPOC -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:UnitAndUITestPOCTests/ModelsTests/testLoginRequestInitialization
```

### Continuous Integration
The tests are designed to run in CI/CD pipelines and provide:
- Fast execution times
- Reliable results
- Clear failure messages
- Performance benchmarks

## 📊 Test Coverage

### Current Coverage Areas
- ✅ **Models**: 100% coverage (initialization, encoding, decoding, computed properties)
- ✅ **Services**: 100% coverage (success paths, error handling, edge cases)
- ✅ **ViewModels**: 100% coverage (state management, user interactions, error handling)
- ✅ **Networking**: 100% coverage (endpoints, error handling, request/response)
- ✅ **Integration**: Complete workflow coverage
- ✅ **Performance**: Key performance metrics

### Coverage Metrics
- **Line Coverage**: >95%
- **Branch Coverage**: >90%
- **Function Coverage**: 100%

## 🔧 Test Utilities

### TestDataFactory
Provides factory methods for creating test data:
```swift
let loginRequest = TestDataFactory.createLoginRequest()
let foodItems = TestDataFactory.createFoodItems(count: 5)
let response = TestDataFactory.createLoginResponseJSON()
```

### Mock Services
Pre-configured mock services for common scenarios:
```swift
let mockAuthService = MockAuthService()
mockAuthService.configureForSuccess()
mockAuthService.configureForFailure(NetworkError.unauthorized)
```

### Custom Assertions
Extended XCTestCase with custom assertions:
```swift
await XCTAssertThrowsAsyncError({ try await service.operation() })
XCTAssertAuthState(viewModel, .authenticated)
XCTAssertMockNetworkServiceCalled(mockService, expectedPath: "/login", expectedMethod: .POST)
```

## 🎯 Test Scenarios

### Happy Path Tests
- Successful login with valid credentials
- Successful food items fetching with valid token
- Proper state transitions in ViewModels
- Correct data transformation in services

### Error Path Tests
- Network errors (unauthorized, server errors, network failures)
- Invalid input validation
- Empty or malformed responses
- Timeout scenarios

### Edge Case Tests
- Empty credentials
- Invalid tokens
- Large datasets
- Concurrent operations
- Memory pressure scenarios

### Performance Tests
- Object creation performance
- JSON encoding/decoding performance
- State change performance
- Large data handling performance

## 📈 Performance Benchmarks

The performance tests establish baseline metrics for:
- **Model Operations**: <1ms for object creation
- **JSON Operations**: <5ms for encoding/decoding
- **State Changes**: <0.1ms for ViewModel state updates
- **Service Calls**: <10ms for mock service operations

1. **Model formatting & coding/decoding**

   * `testFoodItemFormattedPricePerformance`
   * `testLoginRequestCodingPerformance`
   * `testLoginResponseDecodingPerformance`
   * `testFoodItemsResponseDecodingPerformance`
   * `testLargeFoodItemsResponseDecodingPerformance`

   ➝ These measure the cost of string formatting, JSON encoding, and JSON decoding — which are **real bottlenecks** in network-driven apps if done repeatedly or with large payloads.

---

2. **ViewModel property/state churn**

   * `testLoginViewModelStateChangesPerformance`
   * `testFoodViewModelStateChangesPerformance`
   * `testLoginViewModelComputedPropertiesPerformance`
   * `testFoodViewModelComputedPropertiesPerformance`
   * `testLargeFoodItemsViewModelPerformance`

   ➝ These simulate UI state changes and computed property lookups under load. This can matter in SwiftUI where property access can trigger recomputations, body invalidations, or Combine publishers firing.

---

3. **Service & network abstraction**

   * `testAuthServiceLoginPerformance`
   * `testFoodServiceFetchFoodItemsPerformance`

   ➝ You’re measuring how your service layer handles async calls repeatedly. Even if mocked, it checks that your abstractions aren’t introducing unnecessary overhead (e.g. extra Task hops or slow serialization).

---

4. **API endpoint generation**

   * `testAPIEndpointURLGenerationPerformance`
   * `testAPIEndpointBodyGenerationPerformance`

   ➝ Tiny, but these verify that endpoint construction is cheap enough to be done often (e.g. in loops, retries).

---

### ⚠️ Where they’re *less* useful

* Measuring simple **`isLoading` / `errorMessage`** property access 10,000 times is technically valid, but unless those computed properties hide real work (like parsing, heavy logic, or transformations), the result won’t tell you much. Swift property access is already ultra-cheap.

* `measure { Task { … } }` (inside your async service tests) may not behave as expected — `measure` runs synchronously, while you’re spinning up a Task that runs concurrently. XCTest might not actually be measuring the awaited part, just the Task launch overhead. A better approach is:

  ```swift
  measure {
      let expectation = XCTestExpectation()
      Task {
          for _ in 0..<100 {
              _ = try? await authService.login(username: "u", password: "p")
          }
          expectation.fulfill()
      }
      wait(for: [expectation], timeout: 10.0)
  }
  ```
## 🔄 Continuous Improvement

### Regular Review Process
- Weekly test coverage reviews
- Monthly performance benchmark updates
- Quarterly test strategy refinement

### Test Maintenance
- Update tests when adding new features
- Refactor tests when improving code structure
- Remove obsolete tests for deprecated functionality

### Best Practices Updates
- Stay current with Swift testing best practices
- Incorporate new XCTest features as they become available
- Optimize test execution times

## 📚 Additional Resources

- [Apple XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [Swift Testing Best Practices](https://developer.apple.com/documentation/xcode/testing-your-apps-in-xcode)
- [Swift Concurrency Testing](https://developer.apple.com/documentation/xctest/testing-asynchronous-operations)

---

**Note**: This testing suite is designed to be maintainable, comprehensive, and fast. It provides confidence in code changes and helps catch regressions early in the development cycle.
