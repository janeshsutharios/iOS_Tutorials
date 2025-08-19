# 🚀 Developer Quick Reference

## 📁 Project Structure
```
JWTClient-iOS/
├── App/                    # App entry point & DI container
├── Auth/                   # Authentication & token management
├── Config/                 # Environment configurations
├── Models/                 # Data models & JWT utilities
├── Networking/             # HTTP client & API services
├── UI/                     # SwiftUI views
├── Utils/                  # Error handling & logging
└── Testing/                # Mock implementations
```

## 🔑 Key Files to Understand

### **1. App Entry Point**
- **`JWTClientProApp.swift`**: Main app, dependency injection setup
- **`CompositionRoot.swift`**: Service creation and DI container
- **`RootView`**: Navigation logic between login/dashboard

### **2. Core Services**
- **`AuthService.swift`**: Authentication state, token refresh
- **`APIService.swift`**: API endpoint coordination
- **`HTTPClient.swift`**: Network layer with retry logic

### **3. Data Flow**
- **`DashboardView.swift`**: Main data display, loading states
- **`LoginView.swift`**: User authentication
- **`Models.swift`**: Data structures and JWT utilities

## 🚦 Quick Start Guide

### **1. Adding New API Endpoint**
```swift
// 1. Add to APIService
func fetchNewData(with token: String) async throws -> NewDataType {
    let url = URL(string: "\(config.baseURL)/new-endpoint")!
    return try await http.request(url: url, method: .get, headers: authedHeaders(token))
}

// 2. Add to DashboardData
struct DashboardData {
    var newData: NewDataType?
    var errors: [String: Error] = [:]
}

// 3. Add to fetchDashboardDataAsync
group.addTask {
    let result = await self.fetchWithRetry(auth: auth) { token in
        try await self.fetchNewData(with: token)
    }
    return ("newData", result.map { $0 as Any })
}
```

### **2. Adding New View**
```swift
// 1. Create view
struct NewSectionView: View {
    let data: NewDataType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("New Section").font(.headline)
            // Your content here
        }
        .card()
    }
}

// 2. Add to DashboardView
if let newData = data.newData {
    NewSectionView(data: newData)
}
```

### **3. Adding New Error Type**
```swift
// 1. Add to AppError
enum AppError: LocalizedError, Equatable {
    case newError(String)
    // ... existing cases
}

// 2. Add error description
var errorDescription: String? {
    switch self {
    case .newError(let message): return message
    // ... existing cases
    }
}
```

## 🔧 Common Patterns

### **1. Async/Await Pattern**
```swift
private func someAsyncOperation() async {
    isLoading = true
    defer { isLoading = false }
    
    do {
        let result = try await someService.call()
        // Handle success
    } catch {
        // Handle error
    }
}
```

### **2. State Management**
```swift
@State private var data: SomeType? = nil
@State private var isLoading = false
@State private var error: String? = nil

// Update UI based on state
if isLoading {
    ProgressView()
} else if let error {
    Text(error).foregroundColor(.red)
} else if let data {
    // Show data
}
```

### **3. Environment Object Usage**
```swift
@EnvironmentObject var auth: AuthService

// Access auth state
if auth.isAuthenticated {
    // User is logged in
}

// Call auth methods
try await auth.validAccessToken()
```

## 🧪 Testing Patterns

### **1. Mock Setup**
```swift
override func setUp() async throws {
    mockHTTP = MockHTTPClient()
    store = InMemoryTokenStore()
    config = AppConfig.load(for: .dev)
    service = YourService(config: config, http: mockHTTP, store: store)
}
```

### **2. Mock Responses**
```swift
// Set mock response
let response = SomeResponse(data: "test")
let data = try JSONEncoder().encode(response)
await mockHTTP.setResponse(for: "\(config.baseURL)/endpoint", data: data)
```

### **3. Assertions**
```swift
// Test success case
let result = try await service.someMethod()
XCTAssertEqual(result, expectedValue)

// Test error case
do {
    _ = try await service.someMethod()
    XCTFail("Expected error to be thrown")
} catch {
    XCTAssertTrue(error is AppError)
}
```

## 🚨 Common Issues & Solutions

### **1. Main Actor Isolation**
```swift
// ❌ Problem: Main actor isolation error
@MainActor
class SomeClass {
    func someMethod() async {
        // This might cause issues
    }
}

// ✅ Solution: Use proper actor isolation
@MainActor
class SomeClass {
    func someMethod() async {
        await MainActor.run {
            // UI updates here
        }
    }
}
```

### **2. Token Refresh Issues**
```swift
// ❌ Problem: Multiple refresh calls
// ✅ Solution: Use SingleFlight pattern (already implemented)
try await refreshGate.run {
    // Refresh logic here
}
```

### **3. Loading State Management**
```swift
// ❌ Problem: Loading state conflicts
// ✅ Solution: Use task IDs (already implemented)
let taskID = UUID()
currentTaskID = taskID
// ... operation ...
if currentTaskID == taskID {
    isLoading = false
}
```

## 📱 UI Best Practices

### **1. Loading States**
- Use single spinner for all operations
- Clear data when loading starts
- Show loading immediately on user action

### **2. Error Handling**
- Display user-friendly error messages
- Provide recovery options when possible
- Log errors for debugging

### **3. Accessibility**
- Add proper accessibility labels
- Support VoiceOver navigation
- Use semantic colors and fonts

## 🔒 Security Checklist

- [ ] Tokens stored in Keychain only
- [ ] No hardcoded credentials
- [ ] HTTPS for all network calls
- [ ] Automatic token refresh
- [ ] Secure logout with token revocation
- [ ] Input validation and sanitization

## 🚀 Performance Tips

- [ ] Use concurrent API calls when possible
- [ ] Implement proper loading states
- [ ] Cache data when appropriate
- [ ] Monitor network request counts
- [ ] Use lazy loading for heavy operations

## 📚 Additional Resources

- **Architecture**: See `ARCHITECTURE.md` for detailed design
- **Testing**: See test files for implementation examples
- **Configuration**: See `Config/` folder for environment setup
- **Logging**: Use `AppLogger` for debugging and monitoring

This quick reference should help you understand the codebase structure and common patterns quickly!
