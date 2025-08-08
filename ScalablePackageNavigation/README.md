# ScalablePackageNavigation

A modular iOS application demonstrating scalable package-based navigation architecture using SwiftUI and Swift Package Manager.

## 📱 Overview

This project showcases a clean, modular approach to iOS app development by separating concerns into distinct Swift packages. The application implements a simple pizza ordering system with three main screens: Dashboard, Cart, and Order Summary.

## 🏗️ Architecture

The project follows a modular architecture pattern with the following components:

### Core Packages

1. **AppRouter** - Central navigation and state management
2. **CartPackage** - Shopping cart functionality
3. **OrderSummaryPackage** - Order summary and checkout flow

### Main App

- **ScalablePackageNavigation** - Main iOS application that orchestrates all packages

## 📦 Package Structure

```
ScalablePackageNavigation/
├── AppRouter/                    # Navigation and state management
│   ├── Package.swift
│   └── Sources/AppRouter/
│       └── AppRouter.swift
├── CartPackage/                  # Shopping cart functionality
│   ├── Package.swift
│   └── Sources/CartPackage/
│       └── CartView.swift
├── OrderSummaryPackage/          # Order summary and checkout
│   ├── Package.swift
│   └── Sources/OrderSummaryPackage/
│       └── OrderSummaryView.swift
└── ScalablePackageNavigation/    # Main iOS application
    ├── AppViews/
    │   ├── DashboardView.swift
    │   └── ModularCartApp.swift
    └── ScalablePackageNavigation.xcodeproj/
```

## 🚀 Features

- **Modular Design**: Each feature is contained within its own Swift package
- **Centralized Navigation**: Single router manages all navigation state
- **Shared State Management**: Cart items are shared across all modules
- **SwiftUI Integration**: Modern UI framework with declarative syntax
- **Package Dependencies**: Clean dependency management using Swift Package Manager

## 🛠️ Technical Implementation

### AppRouter Package

The `AppRouter` package serves as the central nervous system of the application:

- **Route Enum**: Defines all possible navigation destinations
- **AppRouter Class**: ObservableObject that manages navigation state and shared data
- **Published Properties**: `path` for navigation stack and `cartItems` for shared cart state

### Navigation Flow

1. **Dashboard** → Add items to cart → Navigate to Cart
2. **Cart** → Review items → Place order → Navigate to Summary
3. **Order Summary** → Complete order → Return to Dashboard

### State Management

- Uses `@EnvironmentObject` to inject the router into all views
- `@Published` properties ensure UI updates when state changes
- Navigation stack is managed through the `path` array

## 📋 Requirements

- iOS 13.0+
- Xcode 14.0+
- Swift 6.2+

## 🏃‍♂️ Getting Started

1. Clone the repository
2. Open `ScalablePackageNavigation.xcodeproj` in Xcode
3. Build and run the project
4. Navigate through the app to see the modular navigation in action

## 🔧 Development

### Adding New Features

1. Create a new Swift package in the project root
2. Define dependencies in `Package.swift`
3. Create your feature views
4. Add new routes to the `Route` enum in `AppRouter`
5. Update the main app's navigation destination switch

### Package Dependencies

- **AppRouter**: No dependencies (core package)
- **CartPackage**: Depends on AppRouter
- **OrderSummaryPackage**: Depends on AppRouter
- **Main App**: Depends on all three packages

## 🎯 Benefits of This Architecture

1. **Scalability**: Easy to add new features as separate packages
2. **Maintainability**: Clear separation of concerns
3. **Reusability**: Packages can be reused in other projects
4. **Testing**: Each package can be tested independently
5. **Team Collaboration**: Different teams can work on different packages
6. **Dependency Management**: Clear dependency graph with Swift Package Manager

## 📚 Code Examples

### Adding Items to Cart
```swift
Button("Add Pizza to Cart") {
    router.cartItems.append("Pizza")
    router.path.append(.cart)
}
```

### Navigation
```swift
router.path.append(.summary)  // Navigate to summary
router.path = []              // Clear navigation stack
```

### Environment Object Usage
```swift
@EnvironmentObject var router: AppRouter
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🆘 Support

For questions or issues, please open an issue in the repository. 