# API Reference

This document provides a comprehensive reference for all public APIs in the ScalablePackageNavigation project.

## AppRouter Package

### Route Enum

**Location**: `AppRouter/Sources/AppRouter/AppRouter.swift`

**Declaration**:
```swift
public enum Route {
    case dashboard
    case cart
    case summary
}
```

**Description**: Defines all possible navigation destinations in the application.

**Cases**:
- `dashboard`: Navigate to the main dashboard view
- `cart`: Navigate to the shopping cart view
- `summary`: Navigate to the order summary view

**Usage**:
```swift
router.path.append(.cart)
router.path.append(.summary)
```

### AppRouter Class

**Location**: `AppRouter/Sources/AppRouter/AppRouter.swift`

**Declaration**:
```swift
@available(iOS 13.0, *)
public class AppRouter: ObservableObject {
    @Published public var path: [Route] = []
    @Published public var cartItems: [String] = []
    public init() {}
}
```

**Description**: Central navigation and state management class that serves as the single source of truth for the application.

**Properties**:

#### path: [Route]
- **Type**: `@Published public var path: [Route]`
- **Description**: Navigation stack that manages the current navigation state
- **Usage**: Used with NavigationStack to control navigation flow
- **Example**:
```swift
NavigationStack(path: $router.path) {
    // Navigation content
}
```

#### cartItems: [String]
- **Type**: `@Published public var cartItems: [String]`
- **Description**: Shared cart data accessible across all modules
- **Usage**: Stores items added to the shopping cart
- **Example**:
```swift
router.cartItems.append("Pizza")
router.cartItems.removeAll()
```

**Methods**:

#### init()
- **Declaration**: `public init()`
- **Description**: Default initializer for AppRouter
- **Usage**: Creates a new instance of AppRouter
- **Example**:
```swift
@StateObject var router = AppRouter()
```

## CartPackage

### CartView

**Location**: `CartPackage/Sources/CartPackage/CartView.swift`

**Declaration**:
```swift
@available(iOS 13.0, *)
public struct CartView: View {
    @EnvironmentObject var router: AppRouter
    public init() {}
    public var body: some View
}
```

**Description**: SwiftUI view that displays the shopping cart contents and allows users to proceed to checkout.

**Dependencies**:
- Requires `AppRouter` to be injected via `@EnvironmentObject`

**Features**:
- Displays all items in the cart
- Provides "Place Order" button to navigate to summary
- Automatically updates when cart items change

**Usage**:
```swift
CartView()
    .environmentObject(router)
```

**UI Elements**:
- Title: "🛒 Cart"
- Dynamic list of cart items
- "Place Order" button

## OrderSummaryPackage

### OrderSummaryView

**Location**: `OrderSummaryPackage/Sources/OrderSummaryPackage/OrderSummaryView.swift`

**Declaration**:
```swift
@available(iOS 13.0, *)
public struct OrderSummaryView: View {
    @EnvironmentObject var router: AppRouter
    public init() {}
    public var body: some View
}
```

**Description**: SwiftUI view that displays the order summary and allows users to complete their order.

**Dependencies**:
- Requires `AppRouter` to be injected via `@EnvironmentObject`

**Features**:
- Displays all ordered items
- Provides "Go to Home" button to return to dashboard
- Clears cart and navigation stack on completion

**Usage**:
```swift
OrderSummaryView()
    .environmentObject(router)
```

**UI Elements**:
- Title: "✅ Order Summary 📦"
- Dynamic list of ordered items
- "Go to Home" button (hides back button)

## Main App

### ScalableNavigationApp

**Location**: `ScalablePackageNavigation/AppViews/ModularCartApp.swift`

**Declaration**:
```swift
@main
struct ScalableNavigationApp: App {
    @StateObject var router = AppRouter()
    var body: some Scene
}
```

**Description**: Main application entry point that sets up the navigation structure and injects dependencies.

**Features**:
- Creates and manages the AppRouter instance
- Sets up NavigationStack with type-safe routing
- Injects router into all child views
- Handles navigation destinations

**Navigation Setup**:
```swift
NavigationStack(path: $router.path) {
    DashboardView()
        .environmentObject(router)
        .navigationDestination(for: Route.self) { route in
            switch route {
            case .cart:
                CartView()
                    .environmentObject(router)
            case .summary:
                OrderSummaryView()
                    .environmentObject(router)
            case .dashboard:
                DashboardView()
                    .environmentObject(router)
            }
        }
}
```

### DashboardView

**Location**: `ScalablePackageNavigation/AppViews/DashboardView.swift`

**Declaration**:
```swift
struct DashboardView: View {
    @EnvironmentObject var router: AppRouter
    var body: some View
}
```

**Description**: Main dashboard view that serves as the entry point for the application.

**Features**:
- Displays application title
- Provides button to add items to cart
- Automatically navigates to cart after adding items

**Usage**:
```swift
DashboardView()
    .environmentObject(router)
```

**UI Elements**:
- Title: "🍕 Dashboard"
- "Add Pizza to Cart" button

## Package Dependencies

### AppRouter Package
- **Dependencies**: None (core package)
- **Exports**: Route enum, AppRouter class

### CartPackage
- **Dependencies**: AppRouter
- **Exports**: CartView

### OrderSummaryPackage
- **Dependencies**: AppRouter
- **Exports**: OrderSummaryView

### Main App
- **Dependencies**: AppRouter, CartPackage, OrderSummaryPackage
- **Exports**: ScalableNavigationApp, DashboardView

## Environment Object Usage

All views in the application use the `@EnvironmentObject` pattern to access the shared AppRouter instance:

```swift
@EnvironmentObject var router: AppRouter
```

**Benefits**:
- Automatic dependency injection
- No need for manual object passing
- SwiftUI lifecycle integration
- Loose coupling between components

## Navigation Patterns

### Adding Items and Navigating
```swift
Button("Add Pizza to Cart") {
    router.cartItems.append("Pizza")
    router.path.append(.cart)
}
```

### Navigating to Summary
```swift
Button("Place Order") {
    router.path.append(.summary)
}
```

### Returning to Dashboard
```swift
Button("Go to Home") {
    router.path = []
    router.cartItems.removeAll()
}
```

## Error Handling

### Navigation Errors
- Type-safe routing prevents invalid navigation
- Compile-time checking ensures route existence
- Graceful handling of missing routes

### State Errors
- Published properties ensure UI consistency
- Automatic state restoration
- No manual synchronization required

## Platform Support

All public APIs are marked with `@available(iOS 13.0, *)` to ensure compatibility with the minimum supported iOS version.

## Version Compatibility

- **Swift**: 6.2+
- **iOS**: 13.0+
- **Xcode**: 14.0+
- **SwiftUI**: Available from iOS 13.0

## Best Practices

### Using the APIs

1. **Always inject AppRouter**: Use `@EnvironmentObject` in all views
2. **Type-safe navigation**: Use the Route enum for all navigation
3. **Shared state**: Access cart items through the router
4. **Clean navigation**: Clear navigation stack when appropriate

### Extending the APIs

1. **Add new routes**: Extend the Route enum
2. **Add new views**: Create new SwiftUI views
3. **Add new packages**: Follow the existing package structure
4. **Maintain dependencies**: Update Package.swift files accordingly 