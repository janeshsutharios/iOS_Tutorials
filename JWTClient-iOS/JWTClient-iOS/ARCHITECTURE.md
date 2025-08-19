# JWT Client iOS - Architecture Documentation

## 🏗️ System Overview

This iOS application demonstrates a production-grade JWT authentication system with clean architecture principles, dependency injection, and comprehensive error handling.

## 🔄 Data Flow Architecture

### 1. App Startup Flow
```
App Launch → AppContainer.make() → Dependency Injection → RootView → Auth Check → Login/Dashboard
```

**Detailed Steps:**
1. **App Launch**: `JWTClientProApp` initializes
2. **Container Creation**: `AppContainer.make()` creates all services
3. **Dependency Injection**: Services are injected into views
4. **Root Navigation**: `RootView` observes auth state
5. **State Routing**: Routes to `LoginView` or `DashboardView`

### 2. Authentication Flow
```
Login → HTTP Request → Token Storage → Auth State Update → Dashboard Navigation
```

**Detailed Steps:**
1. **User Input**: Username/password in `LoginView`
2. **API Call**: `AuthService.login()` makes HTTP request
3. **Token Storage**: Tokens saved to Keychain via `TokenStore`
4. **State Update**: `@Published isAuthenticated` triggers UI update
5. **Navigation**: `RootView` automatically switches to `DashboardView`

### 3. API Data Flow
```
Dashboard → API Service → HTTP Client → Backend → Response → UI Update
```

**Detailed Steps:**
1. **User Action**: Tab switch, pull-to-refresh, or initial load
2. **API Call**: `APIService` methods called with auth token
3. **HTTP Request**: `HTTPClient` makes network calls
4. **Response Handling**: Data decoded and returned
5. **UI Update**: `@State` properties trigger view refresh

### 4. Token Refresh Flow
```
Expired Token → Refresh Check → SingleFlight Coordination → HTTP Refresh → Token Update
```

**Detailed Steps:**
1. **Token Check**: `AuthService.validAccessToken()` validates JWT
2. **Expiry Detection**: `JWT.isExpired()` checks token validity
3. **Coordination**: `SingleFlight` prevents duplicate refresh calls
4. **HTTP Refresh**: Single `/refresh` endpoint call
5. **Token Update**: New token stored and returned

## 🏛️ Architecture Layers

### **Presentation Layer (UI)**
- **Views**: `LoginView`, `DashboardView`, `RootView`
- **State Management**: `@State`, `@EnvironmentObject`
- **User Interaction**: Button taps, form submissions, pull-to-refresh

### **Business Logic Layer (Services)**
- **AuthService**: Authentication state management, token lifecycle
- **APIService**: API endpoint coordination, data fetching
- **SingleFlight**: Concurrent operation coordination

### **Data Layer (Network & Storage)**
- **HTTPClient**: Network requests, retry logic, timeout handling
- **TokenStore**: Secure token persistence (Keychain)
- **AppConfig**: Environment-specific configuration

### **Infrastructure Layer**
- **Dependency Injection**: `AppContainer` manages service creation
- **Error Handling**: `AppError` enum with user-friendly messages
- **Logging**: `AppLogger` for debugging and monitoring

## 🔧 Key Design Patterns

### **1. Dependency Injection**
```swift
@State private var container = AppContainer.make(current: .dev)
.environmentObject(container.authService)
```
- **Benefits**: Testability, modularity, loose coupling
- **Implementation**: `AppContainer` creates and injects all services

### **2. Protocol-Oriented Programming**
```swift
protocol HTTPClientProtocol { ... }
protocol TokenStore { ... }
protocol AuthProviding { ... }
```
- **Benefits**: Mocking for tests, interface abstraction
- **Usage**: All major services implement protocols

### **3. SingleFlight Pattern**
```swift
actor SingleFlight {
    func run(_ operation: @escaping () async throws -> Void) async throws
}
```
- **Purpose**: Prevents duplicate concurrent operations
- **Usage**: Token refresh coordination

### **4. Repository Pattern**
```swift
protocol TokenStore {
    func save(accessToken: String?, refreshToken: String?) throws
    func load() throws -> (accessToken: String?, refreshToken: String?)
}
```
- **Benefits**: Data access abstraction, testability
- **Implementation**: `KeychainTokenStore` for production, `InMemoryTokenStore` for tests

## 🚀 Performance Optimizations

### **1. Concurrent API Calls**
```swift
await withTaskGroup(of: (String, Result<Any, Error>).self) { group in
    group.addTask { /* Profile API */ }
    group.addTask { /* Restaurants API */ }
    group.addTask { /* Festivals API */ }
    group.addTask { /* Users API */ }
}
```
- **Benefit**: Parallel execution of independent API calls
- **Result**: Faster dashboard loading

### **2. Token Refresh Coordination**
```swift
// Only one refresh call instead of 4 simultaneous calls
if let existingTask = refreshTask {
    return try await existingTask.value
}
```
- **Benefit**: Eliminates duplicate network requests
- **Result**: Reduced server load, better performance

### **3. Lazy Loading**
```swift
// Data only fetched when needed
private func fetchData() async {
    if selectedMode == 0 {
        data = await api.fetchDashboardDataAsync(auth: auth)
    }
}
```
- **Benefit**: On-demand data fetching
- **Result**: Faster app startup, reduced memory usage

## 🧪 Testing Strategy

### **1. Mock Implementations**
```swift
final class MockHTTPClient: HTTPClientProtocol { ... }
final class InMemoryTokenStore: TokenStore { ... }
```
- **Purpose**: Isolated unit testing
- **Coverage**: HTTP responses, token storage, error scenarios

### **2. Test Categories**
- **Unit Tests**: Individual service methods
- **Integration Tests**: Service interactions
- **UI Tests**: User flow validation

### **3. Test Data**
```swift
extension JWT {
    static func createMockToken(expiresIn: TimeInterval) -> String
    static func createExpiredMockToken() -> String
}
```
- **Purpose**: Consistent test data generation
- **Usage**: Token validation, expiry scenarios

## 🔒 Security Features

### **1. Token Storage**
- **Keychain**: Secure token persistence
- **No Hardcoding**: Tokens never stored in code
- **Automatic Cleanup**: Tokens cleared on logout

### **2. JWT Validation**
```swift
if let token = accessToken, !JWT.isExpired(token) {
    return token
}
```
- **Purpose**: Automatic token expiry detection
- **Benefit**: Proactive token refresh

### **3. Network Security**
- **HTTPS Only**: All API calls use secure connections
- **Token Rotation**: Refresh token rotation support
- **Session Management**: Automatic logout on auth failure

## 📱 User Experience Features

### **1. Loading States**
- **Unified Loading**: Single spinner for all operations
- **Smooth Transitions**: No jarring UI changes
- **Error Handling**: User-friendly error messages

### **2. Offline Support**
- **Token Persistence**: Works offline with valid tokens
- **Graceful Degradation**: Clear error messages for network issues

### **3. Accessibility**
- **VoiceOver Support**: Proper accessibility labels
- **Dynamic Type**: Scalable text sizes
- **High Contrast**: Dark/light mode support

## 🔄 State Management

### **1. Authentication State**
```swift
@Published private(set) var isAuthenticated: Bool = false
@Published var authMessage: String? = nil
```
- **Purpose**: Centralized auth state management
- **Usage**: UI routing, user feedback

### **2. Data State**
```swift
@State private var data: DashboardData? = nil
@State private var isLoading = false
@State private var error: String? = nil
```
- **Purpose**: Local view state management
- **Usage**: Loading indicators, error display

### **3. Task Management**
```swift
@State private var currentTask: Task<Void, Never>?
@State private var currentTaskID = UUID()
```
- **Purpose**: Async operation coordination
- **Usage**: Cancellation, loading state protection

## 🚀 Scalability Considerations

### **1. Service Modularity**
- **Independent Services**: Each service has single responsibility
- **Protocol Interfaces**: Easy to swap implementations
- **Configuration Driven**: Environment-specific settings

### **2. Error Handling**
- **Comprehensive Coverage**: All error scenarios handled
- **User Feedback**: Clear error messages
- **Recovery Mechanisms**: Automatic retry, graceful fallbacks

### **3. Performance Monitoring**
- **Request Tracking**: Request counts and timing
- **Error Logging**: Comprehensive error logging
- **Performance Metrics**: Response time monitoring

This architecture provides a solid foundation for a scalable, maintainable iOS application with excellent testability and user experience.
