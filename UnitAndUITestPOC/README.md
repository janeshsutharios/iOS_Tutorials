# Food App - SwiftUI with Comprehensive Testing

A modern SwiftUI application demonstrating best practices in iOS development with comprehensive unit tests, integration tests, and UI tests. **Fully compatible with Swift 6** and featuring the new **Swift Testing framework**.

## 🏗️ Architecture

This project follows the **MVVM (Model-View-ViewModel)** architecture pattern with clean separation of concerns:

### Core Components

- **Models**: Data structures for authentication and food items
- **Services**: Business logic layer for API communication
- **ViewModels**: State management and business logic for UI
- **Views**: SwiftUI user interface components
- **Networking**: Protocol-based network layer with error handling

### Project Structure

```
UnitAndUITestPOC/
├── UnitAndUITestPOC/
│   ├── Models/
│   │   ├── AuthModels.swift
│   │   └── FoodModels.swift
│   ├── Networking/
│   │   ├── NetworkError.swift
│   │   ├── NetworkService.swift
│   │   └── APIEndpoint.swift
│   ├── Services/
│   │   ├── AuthService.swift
│   │   └── FoodService.swift
│   ├── ViewModels/
│   │   ├── LoginViewModel.swift
│   │   └── FoodViewModel.swift
│   ├── Views/
│   │   ├── LoginView.swift
│   │   ├── FoodListView.swift
│   │   └── FoodItemCard.swift
│   ├── ContentView.swift
│   └── UnitAndUITestPOCApp.swift
├── UnitAndUITestPOCTests/
│   ├── Models/
│   ├── Networking/
│   ├── Services/
│   ├── ViewModels/
│   ├── Integration/
│   ├── Mocks/
│   └── SwiftTesting/          # New Swift Testing framework tests
└── UnitAndUITestPOCUITests/
    ├── LoginUITests.swift
    └── FoodListUITests.swift
```

## 🚀 Features

### Authentication
- Beautiful login screen with gradient background
- Username/password validation
- Password visibility toggle
- Loading states and error handling
- JWT token management

### Food Menu
- Grid layout displaying food items
- Async image loading with placeholder states
- Pull-to-refresh functionality
- Error handling with retry options
- Responsive design

### User Experience
- Smooth navigation between screens
- Loading indicators
- Error messages with user-friendly text
- Modern UI with shadows and animations

## 🧪 Testing Strategy

This project demonstrates comprehensive testing following iOS best practices with **both XCTest and Swift Testing frameworks**:

### 1. Unit Tests (XCTest)
**Scope**: Individual functions, structs, and classes
**Goal**: Verify correctness of logic in isolation

#### Models Tests
- `AuthModelsTests.swift`: Tests for login request/response encoding/decoding
- `FoodModelsTests.swift`: Tests for food item data structures and computed properties

#### Networking Tests
- `NetworkErrorTests.swift`: Tests for error handling and descriptions
- `APIEndpointTests.swift`: Tests for API endpoint configuration

#### Services Tests
- `AuthServiceTests.swift`: Tests for authentication service with mocked dependencies
- `FoodServiceTests.swift`: Tests for food service with mocked dependencies

#### ViewModels Tests
- `LoginViewModelTests.swift`: Tests for login logic and state management
- `FoodViewModelTests.swift`: Tests for food fetching logic and state management

### 2. Swift Testing Framework Tests 🆕
**Framework**: [Swift Testing](https://developer.apple.com/xcode/swift-testing/)
**Features**: Modern testing with macros, parameterized tests, and better async support

#### Swift Testing Examples
- `AuthModelsSwiftTests.swift`: Modern tests using `#expect` macro
- `FoodModelsSwiftTests.swift`: Parameterized tests for price formatting
- `ServicesSwiftTests.swift`: Async/await testing with better error handling
- `ViewModelsSwiftTests.swift`: Comprehensive state management tests
- `IntegrationSwiftTests.swift`: End-to-end flow testing

#### Swift Testing Benefits
- **Clear, expressive API**: Uses macros for better readability
- **Parameterized tests**: Run same test with multiple values
- **Better async support**: Native async/await testing
- **Parallel execution**: Tests run in parallel by default
- **Rich tooling**: Better integration with Xcode

### 3. Mock Objects (Test Doubles)
**Purpose**: Isolate dependencies in unit tests

- `MockNetworkService`: Simulates network responses and errors
- `MockAuthService`: Simulates authentication operations
- `MockFoodService`: Simulates food item fetching

### 4. Integration Tests
**Scope**: Multiple components working together
**Goal**: Ensure components integrate correctly

- `IntegrationTests.swift`: Tests the complete flow from login to food fetching
- Tests dependency injection patterns
- Tests error propagation through the system

### 5. UI Tests (End-to-End)
**Scope**: Full app workflow from user perspective
**Tool**: XCUITest framework

- `LoginUITests.swift`: Tests login screen interactions
- `FoodListUITests.swift`: Tests food list screen interactions

## 🛠️ Technical Implementation

### Swift 6 Compatibility 🆕
This project is fully compatible with Swift 6 and includes:

- **Sendable Conformance**: All models and protocols conform to `Sendable`
- **Actor Isolation**: Services use actors for thread safety
- **Modern Concurrency**: Full async/await support throughout
- **Type Safety**: Improved type checking and error handling

### Dependency Injection
All services and view models use protocol-based dependency injection for testability:

```swift
protocol NetworkServiceProtocol: Sendable {
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T
}

actor AuthService: AuthServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
}
```

### Error Handling
Comprehensive error handling with custom `NetworkError` enum:

```swift
enum NetworkError: LocalizedError, Equatable, Sendable {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case networkError(Error)
    case unauthorized
    case unknown
}
```

### State Management
Clean state management using enums and `@Published` properties:

```swift
enum AuthState: Equatable, Sendable {
    case idle
    case loading
    case authenticated
    case error(String)
}
```

## 🏃‍♂️ Running the App

### Prerequisites
- Xcode 16.0+ (for Swift Testing framework)
- iOS 17.0+
- Swift 6.0+

### Setup
1. Clone the repository
2. Open `UnitAndUITestPOC.xcodeproj` in Xcode
3. Build and run the project

### Demo Credentials
- Username: `test`
- Password: `password`

## 🧪 Running Tests

### XCTest (Traditional)
```bash
# Run all unit tests
xcodebuild test -scheme UnitAndUITestPOC -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test class
xcodebuild test -scheme UnitAndUITestPOC -only-testing:UnitAndUITestPOCTests/LoginViewModelTests
```

### Swift Testing Framework 🆕
```bash
# Run Swift Testing framework tests
swift test

# Run specific Swift Testing suite
swift test --filter AuthModelsSwiftTests
```

### UI Tests
```bash
# Run all UI tests
xcodebuild test -scheme UnitAndUITestPOC -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:UnitAndUITestPOCUITests
```

## 📊 Test Coverage

The project aims for comprehensive test coverage:

- **Models**: 100% coverage for data structures
- **Services**: 100% coverage with mocked dependencies
- **ViewModels**: 100% coverage for business logic
- **Networking**: 100% coverage for error scenarios
- **UI**: Critical user flows covered
- **Swift Testing**: Modern testing patterns demonstrated

## 🔧 API Endpoints

The app connects to a local server running on `http://localhost:3000`:

### Login
```
POST /login
{
    "username": "test",
    "password": "password"
}
```

### Food Items
```
GET /food-items
Authorization: Bearer <access_token>
```

## 🎯 Best Practices Demonstrated

1. **Protocol-Oriented Programming**: All dependencies use protocols
2. **Dependency Injection**: Services and view models are injectable
3. **Error Handling**: Comprehensive error handling with user-friendly messages
4. **State Management**: Clean state management with enums
5. **Async/Await**: Modern concurrency patterns
6. **Testing**: Comprehensive test coverage with both XCTest and Swift Testing
7. **UI/UX**: Modern, accessible, and responsive design
8. **Code Organization**: Clear separation of concerns
9. **Swift 6 Compatibility**: Future-proof code with latest Swift features
10. **Documentation**: Well-documented code and architecture

## 🆕 Swift Testing Framework Features

### Parameterized Tests
```swift
@Test("FoodItem formatted price calculation", arguments: [
    (9.99, "$9.99"),
    (10.0, "$10.00"),
    (0.0, "$0.00"),
    (123.45, "$123.45")
])
func testFoodItemFormattedPrice(price: Double, expected: String) {
    let foodItem = FoodItem(/* ... */)
    #expect(foodItem.formattedPrice == expected)
}
```

### Async Testing
```swift
@Test("AuthService login success")
func testAuthServiceLoginSuccess() async throws {
    let mockNetworkService = MockNetworkService()
    let authService = AuthService(networkService: mockNetworkService)
    let result = try await authService.login(username: "test", password: "pass")
    #expect(result.accessToken == "test-token")
}
```

### Test Organization
```swift
@Suite("Authentication Models")
struct AuthModelsSwiftTests {
    @Test("LoginRequest encoding produces valid JSON")
    func testLoginRequestEncoding() throws {
        // Test implementation
    }
}
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality (preferably using Swift Testing framework)
4. Ensure all tests pass
5. Submit a pull request

## 📝 License

This project is for educational purposes and demonstrates iOS development best practices with Swift 6 and modern testing approaches.
