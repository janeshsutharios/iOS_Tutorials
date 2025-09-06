# Scalable iOS App Architecture with Swift Package Manager

This project demonstrates a **highly scalable iOS application architecture** using Swift Package Manager with complete separation of concerns and modular design. Built with **Swift 6.2** and modern async/await patterns.

## 🏗️ Architecture Overview

The app is structured into **6 independent packages** plus a main app target:

```
ScalablePackageNavigation-Level-2/
├── ScalablePackageNavigation-Level-2/    # Main Application
├── CoreNavigation/                       # Navigation infrastructure
├── Auth/                                # Authentication module
├── Dashboard/                           # Dashboard feature
├── Messages/                            # Messaging feature
├── Profile/                             # Profile management
└── Services/                            # Shared services & data models
```

## 📦 Package Structure

### 1. **CoreNavigation Package** 🧭
**Foundation for all navigation in the app**
- `Router.swift` - Protocol and BaseRouter implementation
- `NavigationPath+Extensions.swift` - Navigation utilities
- `CoreNavigation.swift` - Module definition

**Dependencies:** None (foundation package)

**Key Features:**
- Protocol-based router system
- Type-safe navigation with enums
- Automatic navigation stack management
- Swift 6.2 compatible with `@MainActor` and `Sendable`

### 2. **Services Package** 🔧
**Shared services and data models**
- `Services.swift` - Service protocols and data models
- `MockServices.swift` - Mock implementations for testing

**Dependencies:** None (foundation package)

**Key Features:**
- Protocol-based services for testability
- Async/await patterns for modern concurrency
- Mock implementations for development/testing
- Centralized data models with Sendable conformance

### 3. **Auth Package** 🔐
**Complete authentication flow**
- `Auth.swift` - Auth routes and navigation container
- `LoginView.swift` - Login interface
- `SignupView.swift` - Registration interface
- `ForgotPasswordView.swift` - Password recovery
- `VerificationView.swift` - Email/SMS verification

**Dependencies:** CoreNavigation, Services

### 4. **Dashboard Package** 📊
**Dashboard and home management**
- `Dashboard.swift` - Dashboard routes and navigation container
- `HomeView.swift` - Main dashboard view
- `DetailView.swift` - Detail view for dashboard items

**Dependencies:** CoreNavigation, Services

### 5. **Messages Package** 💬
**Complete messaging system**
- `Messages.swift` - Messages routes and navigation container
- `InboxView.swift` - Message inbox
- `ConversationView.swift` - Individual conversations
- `ComposeView.swift` - Message composition
- `SearchView.swift` - Message search

**Dependencies:** CoreNavigation, Services

### 6. **Profile Package** 👤
**User profile and settings management**
- `ProfileRoute.swift` - Profile routes and navigation container
- `ProfileView.swift` - User profile display
- `SettingsView.swift` - App settings

**Dependencies:** CoreNavigation, Services

## 🔄 Dependency Graph

```
Main App → Auth, Dashboard, Messages, Profile, Services, CoreNavigation
Auth → CoreNavigation, Services
Dashboard → CoreNavigation, Services  
Messages → CoreNavigation, Services
Profile → CoreNavigation, Services
Services → (No dependencies)
CoreNavigation → (No dependencies)
```

## ✨ Key Features

### 🎯 **Complete Separation**
- Each feature is in its own package
- No circular dependencies
- Clear boundaries between modules

### 🚀 **Independent Development**
- Teams can work on different packages simultaneously
- Each package can be versioned independently
- Easy to add new features as separate packages

### 🧪 **Testability**
- Each package can be tested in isolation
- Mock services for easy testing
- Protocol-based architecture for dependency injection

### 🔄 **Reusability**
- Packages can be reused across different projects
- Services are protocol-based for easy swapping
- Navigation infrastructure is shared

### 📈 **Scalability**
- Easy to add new features as separate packages
- Clear dependency management
- Modular architecture supports team growth

### ⚡ **Swift 6.2 Compatibility**
- **Modern async/await patterns** instead of Combine
- **Sendable conformance** for all data models and protocols
- **Strict concurrency checking** enabled
- **@MainActor** annotations for UI-related classes
- **@unchecked Sendable** where appropriate for reference types

## 🛠️ Implementation Details

### **Navigation System**
- Protocol-based router system with `Router` protocol
- Type-safe navigation with route enums
- Automatic navigation stack management with `NavigationPath`
- Support for deep linking and programmatic navigation

### **Service Layer**
- Protocol-based services for testability
- **Async/await patterns** for modern concurrency
- Mock implementations for development/testing
- Centralized data models with Sendable conformance

### **App Coordinator Pattern**
- Centralized app state management
- Service and router coordination
- Authentication flow management
- Tab-based navigation structure

## 🚀 Getting Started

### **Prerequisites**
- Xcode 15.0+
- iOS 18.0+ (or adjust platform targets as needed)
- Swift 6.2

### **Setup**
1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ScalablePackageNavigation-Level-2
   ```

2. **Open in Xcode**
   ```bash
   open ScalablePackageNavigation-Level-2.xcodeproj
   ```

3. **Build and Run**
   - Select your target device/simulator
   - Press `Cmd + R` to build and run

### **Demo Credentials**
- **Email:** `demo@example.com`
- **Password:** `password123`
- **Verification Code:** `123456`

## 🧪 Testing

Each package includes comprehensive test targets:

```bash
# Run tests for specific package
cd CoreNavigation && swift test
cd Dashboard && swift test
cd Messages && swift test
cd Profile && swift test
cd Auth && swift test
cd Services && swift test
```

### **Test Coverage**
- Unit tests for ViewModels and services
- Integration tests for navigation flows
- Mock service testing
- Router functionality validation

## 📱 App Flow

### **Authentication Flow**
1. **Login** - Email/password authentication
2. **Signup** - New user registration
3. **Forgot Password** - Password recovery
4. **Verification** - Email/SMS verification

### **Main App Flow**
1. **Dashboard** - Home screen with overview
2. **Messages** - Inbox, conversations, compose
3. **Profile** - User profile and settings
4. **Navigation** - Seamless navigation between all features

## 🔧 Development Guide

### **Adding New Features**

1. **Create a new package:**
   ```bash
   mkdir NewFeature
   cd NewFeature
   swift package init --type library
   ```

2. **Update Package.swift:**
   ```swift
   dependencies: [
       .package(path: "../CoreNavigation"),
       .package(path: "../Services"),
   ]
   ```

3. **Follow the established patterns:**
   - Create route enums
   - Implement router classes
   - Create navigation containers
   - Add views and ViewModels

### **Service Updates**
- Update protocols first, then implementations
- Maintain backward compatibility
- Use async/await patterns
- Ensure Sendable conformance

### **Navigation Changes**
- Update route enums
- Modify navigation containers
- Test navigation flows
- Update deep linking if needed

## 📋 Architecture Benefits

- ✅ **Complete Separation** - Each feature is independent
- ✅ **Team Scalability** - Multiple teams can work simultaneously
- ✅ **Testability** - Each package can be tested in isolation
- ✅ **Reusability** - Packages can be reused across projects
- ✅ **Maintainability** - Clear boundaries and dependencies
- ✅ **Performance** - Only load what you need
- ✅ **CI/CD Ready** - Each package can have its own pipeline
- ✅ **Swift 6.2 Ready** - Modern concurrency and strict checking
- ✅ **Future Proof** - Built with latest Swift features

## 🚀 Swift 6.2 Features Used

### **Concurrency**
- **async/await** for all service calls
- **@MainActor** for UI-related classes
- **Sendable** protocols and data models
- **Task** for concurrent operations

### **Type Safety**
- **@unchecked Sendable** for reference types where safe
- **final class** declarations for better performance
- **Strict concurrency checking** enabled

### **Modern Patterns**
- Protocol-based architecture with Sendable conformance
- Clean separation of concerns with concurrency safety
- ObservableObject for reactive UI updates

## 🔍 Code Examples

### **Router Implementation**
```swift
@MainActor
public final class DashboardRouter: BaseRouter<DashboardRoute> {
    public override init() {
        super.init()
    }
}
```

### **Navigation Container**
```swift
public struct DashboardNavigationContainer: View {
    @StateObject private var router = DashboardRouter()
    
    public var body: some View {
        NavigationStack(path: $router.navigationPath) {
            HomeView()
                .navigationDestination(for: DashboardRoute.self) { route in
                    destinationView(for: route)
                }
        }
        .environmentObject(router)
    }
}
```

### **Service Protocol**
```swift
public protocol AuthServiceProtocol: Sendable {
    func login(email: String, password: String) async throws -> Bool
    func signup(email: String, password: String) async throws -> Bool
    func logout() async throws -> Bool
    var isAuthenticated: Bool { get async }
}
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Follow the established architecture patterns
4. Add tests for new functionality
5. Ensure all packages build successfully
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Built with Swift 6.2 and SwiftUI
- Uses Swift Package Manager for dependency management
- Follows Apple's recommended architecture patterns
- Inspired by modern iOS development best practices

---

**Built with ❤️ for scalable iOS development**

This architecture provides a solid foundation for building large-scale iOS applications that can grow with your team and feature set, while being fully compatible with Swift 6.2's modern concurrency model.
