# Scalable Package Navigation

A SwiftUI iOS app demonstrating modular architecture with Swift Package Manager and enum-based navigation using associated values.

## 🏗️ Architecture

This project uses a **modular package-based architecture** where each major feature is contained in its own Swift package:

- **AppRouter**: Core navigation and routing logic
- **CartPackage**: Shopping cart functionality
- **OrderSummaryPackage**: Order confirmation and summary
- **ScalablePackageNavigation**: Main iOS app container

## 🧭 Navigation System

The app uses **enum with associated values** for type-safe navigation:

```swift
public enum Route: Hashable {
    case dashboard
    case cart(cartItems: [String])           // Pass cart items to cart view
    case summary(orderedItems: [String])    // Pass ordered items to summary
}
```

### Navigation Flow

1. **Dashboard** → Add items to cart
2. **Cart View** → Display cart items, proceed to checkout
3. **Order Summary** → Show ordered items, return to home

## 📱 Key Features

- **Modular Design**: Each feature in its own Swift package
- **Type-Safe Navigation**: Enum associated values ensure data consistency
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for state management
- **iOS 13+**: Broad device compatibility

## 🚀 Getting Started

1. Open `ScalablePackageNavigation.xcodeproj` in Xcode
2. Build and run the project
3. Navigate through the app to see the modular architecture in action

## 📦 Package Structure

```
ScalablePackageNavigation/
├── AppRouter/           # Navigation and routing
├── CartPackage/         # Shopping cart functionality  
├── OrderSummaryPackage/ # Order summary and confirmation
├── ScalablePackageNavigation/ # Main iOS app
└── docs/               # Documentation
```

## 🔧 Requirements

- iOS 13.0+
- Xcode 26+
- Swift 6.2+

## 📖 Usage Example

```swift
// Navigate to cart with items
router.path.append(.cart(cartItems: ["🍕 Pizza", "☕ Coffee"]))

// Navigate to summary with ordered items
router.path.append(.summary(orderedItems: cartItems))
```

## 🎯 Benefits

- **Scalability**: Easy to add new features as packages
- **Maintainability**: Clear separation of concerns
- **Reusability**: Packages can be used in other projects
- **Type Safety**: Compile-time navigation validation
- **Performance**: Efficient navigation with associated values

## 🤝 Contributing

This project demonstrates best practices for iOS modular architecture. Feel free to explore and adapt the patterns for your own projects.
