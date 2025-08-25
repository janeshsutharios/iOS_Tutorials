# Food App - SwiftUI with Comprehensive Testing

A modern SwiftUI application demonstrating best practices in iOS development with comprehensive unit tests, integration tests, and UI tests.

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
│   └── Mocks/
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

This project demonstrates comprehensive testing following iOS best practices:

### 1. Unit Tests
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

### 2. Mock Objects (Test Doubles)
**Purpose**: Isolate dependencies in unit tests

- `MockNetworkService`: Simulates network responses and errors
- `MockAuthService`: Simulates authentication operations
- `MockFoodService`: Simulates food item fetching

### 3. Integration Tests
**Scope**: Multiple components working together
**Goal**: Ensure components integrate correctly

- `IntegrationTests.swift`: Tests the complete flow from login to food fetching
- Tests dependency injection patterns
- Tests error propagation through the system

### 4. UI Tests (End-to-End)
**Scope**: Full app workflow from user perspective
**Tool**: XCUITest framework

- `LoginUITests.swift`: Tests login screen interactions
- `FoodListUITests.swift`: Tests food list screen interactions

## 🛠️ Technical Implementation

### Dependency Injection
All services and view models use protocol-based dependency injection for testability:

```swift
protocol NetworkServiceProtocol {
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T
}

class AuthService: AuthServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
}
```

### Error Handling
Comprehensive error handling with custom `NetworkError` enum:

```swift
enum NetworkError: LocalizedError, Equatable {
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
enum AuthState {
    case idle
    case loading
    case authenticated
    case error(String)
}
```

## 🏃‍♂️ Running the App

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Setup
1. Clone the repository
2. Open `UnitAndUITestPOC.xcodeproj` in Xcode
3. Build and run the project

### Demo Credentials
- Username: `test`
- Password: `password`

## 🧪 Running Tests

### Unit Tests
```bash
# Run all unit tests
xcodebuild test -scheme UnitAndUITestPOC -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test class
xcodebuild test -scheme UnitAndUITestPOC -only-testing:UnitAndUITestPOCTests/LoginViewModelTests
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
6. **Testing**: Comprehensive test coverage with mocks
7. **UI/UX**: Modern, accessible, and responsive design
8. **Code Organization**: Clear separation of concerns
9. **Documentation**: Well-documented code and architecture

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## 📝 License

This project is for educational purposes and demonstrates iOS development best practices.
