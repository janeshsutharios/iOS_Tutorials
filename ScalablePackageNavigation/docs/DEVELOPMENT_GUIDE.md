# Development Guide

This guide provides step-by-step instructions for developers working on the ScalablePackageNavigation project.

## Prerequisites

Before you begin development, ensure you have the following installed:

- **Xcode 14.0+** (Latest version recommended)
- **iOS 13.0+** (Minimum supported version)
- **Swift 6.2+**
- **Git** for version control

## Project Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd ScalablePackageNavigation
```

### 2. Open the Project

Open the project in Xcode:

```bash
open ScalablePackageNavigation.xcodeproj
```

Or navigate to the project folder and double-click the `.xcodeproj` file.

### 3. Build and Run

1. Select your target device or simulator
2. Press `Cmd + R` or click the "Run" button
3. The app should launch and display the Dashboard

## Project Structure

### Understanding the Architecture

The project follows a modular architecture with the following components:

```
ScalablePackageNavigation/
├── AppRouter/                    # Core navigation package
├── CartPackage/                  # Shopping cart functionality
├── OrderSummaryPackage/          # Order summary functionality
└── ScalablePackageNavigation/    # Main iOS app
```

### Package Dependencies

```
Main App
├── AppRouter (Core)
├── CartPackage
│   └── AppRouter
└── OrderSummaryPackage
    └── AppRouter
```

## Development Workflow

### 1. Making Changes to Existing Features

#### Modifying the Dashboard

**File**: `ScalablePackageNavigation/AppViews/DashboardView.swift`

```swift
struct DashboardView: View {
    @EnvironmentObject var router: AppRouter

    var body: some View {
        VStack(spacing: 20) {
            Text("🍕 Dashboard")
                .font(.largeTitle)
            Button("Add Pizza to Cart") {
                router.cartItems.append("Pizza")
                router.path.append(.cart)
            }
        }
    }
}
```

**Common modifications**:
- Add new UI elements
- Modify button actions
- Change styling and layout

#### Modifying Cart Functionality

**File**: `CartPackage/Sources/CartPackage/CartView.swift`

```swift
public struct CartView: View {
    @EnvironmentObject var router: AppRouter

    public var body: some View {
        VStack(spacing: 20) {
            Text("🛒 Cart")
                .font(.largeTitle)
            ForEach(router.cartItems, id: \.self) { item in
                Text(item)
            }
            Button("Place Order") {
                router.path.append(.summary)
            }
        }
    }
}
```

**Common modifications**:
- Add item removal functionality
- Modify cart item display
- Add quantity controls

#### Modifying Order Summary

**File**: `OrderSummaryPackage/Sources/OrderSummaryPackage/OrderSummaryView.swift`

```swift
public struct OrderSummaryView: View {
    @EnvironmentObject var router: AppRouter

    public var body: some View {
        VStack(spacing: 20) {
            Text("✅ Order Summary 📦")
                .font(.largeTitle)
            ForEach(router.cartItems, id: \.self) { item in
                Text("Ordered: \(item)")
            }
            Button("Go to Home") {
                router.path = []
                router.cartItems.removeAll()
            }
            .navigationBarBackButtonHidden()
        }
    }
}
```

**Common modifications**:
- Add order confirmation details
- Modify completion flow
- Add order history

### 2. Adding New Features

#### Step 1: Create a New Package

1. Create a new directory in the project root:
```bash
mkdir NewFeaturePackage
cd NewFeaturePackage
```

2. Create the package structure:
```bash
mkdir -p Sources/NewFeaturePackage
```

3. Create `Package.swift`:
```swift
// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "NewFeaturePackage",
    products: [
        .library(
            name: "NewFeaturePackage",
            targets: ["NewFeaturePackage"]
        ),
    ],
    dependencies: [
        .package(name: "AppRouter", path: "../AppRouter")
    ],
    targets: [
        .target(
            name: "NewFeaturePackage",
            dependencies: ["AppRouter"]
        ),
    ]
)
```

#### Step 2: Create Your Feature View

**File**: `NewFeaturePackage/Sources/NewFeaturePackage/NewFeatureView.swift`

```swift
import SwiftUI
import AppRouter

@available(iOS 13.0, *)
public struct NewFeatureView: View {
    @EnvironmentObject var router: AppRouter

    public init() {}

    public var body: some View {
        VStack(spacing: 20) {
            Text("🆕 New Feature")
                .font(.largeTitle)
            
            // Your feature content here
            
            Button("Back to Dashboard") {
                router.path = []
            }
        }
    }
}
```

#### Step 3: Add New Route

**File**: `AppRouter/Sources/AppRouter/AppRouter.swift`

```swift
public enum Route {
    case dashboard
    case cart
    case summary
    case newFeature  // Add this line
}
```

#### Step 4: Update Navigation

**File**: `ScalablePackageNavigation/AppViews/ModularCartApp.swift`

```swift
import NewFeaturePackage  // Add this import

// In the navigationDestination switch:
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
case .newFeature:  // Add this case
    NewFeatureView()
        .environmentObject(router)
}
```

#### Step 5: Add Navigation Trigger

Add a button or action to navigate to your new feature:

```swift
Button("Go to New Feature") {
    router.path.append(.newFeature)
}
```

### 3. Adding New State Properties

#### Step 1: Extend AppRouter

**File**: `AppRouter/Sources/AppRouter/AppRouter.swift`

```swift
@available(iOS 13.0, *)
public class AppRouter: ObservableObject {
    @Published public var path: [Route] = []
    @Published public var cartItems: [String] = []
    @Published public var newProperty: String = ""  // Add this line
    
    public init() {}
}
```

#### Step 2: Use in Views

```swift
@EnvironmentObject var router: AppRouter

// Set the property
router.newProperty = "New Value"

// Read the property
Text(router.newProperty)
```

## Testing

### 1. Manual Testing

1. **Navigation Flow**:
   - Launch app → Dashboard
   - Add item → Cart
   - Place order → Summary
   - Go home → Dashboard

2. **State Management**:
   - Verify cart items persist across navigation
   - Check that clearing cart works properly
   - Test navigation stack behavior

3. **UI Testing**:
   - Test on different device sizes
   - Verify accessibility features
   - Check dark/light mode compatibility

### 2. Unit Testing

Create test files for each package:

**File**: `AppRouter/Tests/AppRouterTests/AppRouterTests.swift`

```swift
import XCTest
@testable import AppRouter

final class AppRouterTests: XCTestCase {
    var router: AppRouter!
    
    override func setUp() {
        super.setUp()
        router = AppRouter()
    }
    
    override func tearDown() {
        router = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertTrue(router.path.isEmpty)
        XCTAssertTrue(router.cartItems.isEmpty)
    }
    
    func testAddCartItem() {
        router.cartItems.append("Pizza")
        XCTAssertEqual(router.cartItems.count, 1)
        XCTAssertEqual(router.cartItems.first, "Pizza")
    }
    
    func testNavigation() {
        router.path.append(.cart)
        XCTAssertEqual(router.path.count, 1)
        XCTAssertEqual(router.path.first, .cart)
    }
}
```

### 3. Integration Testing

Test the complete user flow:

```swift
func testCompleteOrderFlow() {
    // Add item to cart
    router.cartItems.append("Pizza")
    XCTAssertEqual(router.cartItems.count, 1)
    
    // Navigate to cart
    router.path.append(.cart)
    XCTAssertEqual(router.path.count, 1)
    
    // Navigate to summary
    router.path.append(.summary)
    XCTAssertEqual(router.path.count, 2)
    
    // Complete order
    router.path = []
    router.cartItems.removeAll()
    XCTAssertTrue(router.path.isEmpty)
    XCTAssertTrue(router.cartItems.isEmpty)
}
```

## Debugging

### 1. Common Issues

#### Navigation Not Working
- Check that `@EnvironmentObject var router: AppRouter` is present
- Verify the route is added to the `Route` enum
- Ensure the navigation destination case is handled

#### State Not Updating
- Verify `@Published` properties are used
- Check that `@EnvironmentObject` is properly injected
- Ensure UI updates are on the main thread

#### Build Errors
- Check package dependencies in `Package.swift`
- Verify import statements
- Ensure Swift version compatibility

### 2. Debugging Tools

#### Print Debugging
```swift
print("Cart items: \(router.cartItems)")
print("Navigation path: \(router.path)")
```

#### Xcode Debugger
- Set breakpoints in navigation methods
- Inspect router state in debugger
- Use Xcode's view hierarchy debugger

## Performance Optimization

### 1. Memory Management
- Environment objects are managed by SwiftUI
- No manual memory management required
- Automatic cleanup when views are deallocated

### 2. Navigation Performance
- NavigationStack provides efficient navigation
- Lazy loading of destination views
- Minimal memory footprint

### 3. State Updates
- `@Published` properties optimize UI updates
- Only changed properties trigger view updates
- Efficient diffing and rendering

## Code Style Guidelines

### 1. SwiftUI Conventions
- Use `@EnvironmentObject` for dependency injection
- Prefer `@Published` properties for state
- Use semantic naming for views and properties

### 2. Package Structure
- Keep packages focused on single responsibility
- Use clear, descriptive package names
- Maintain consistent file organization

### 3. Documentation
- Add comments for complex logic
- Document public APIs
- Include usage examples

## Deployment

### 1. Build Configuration
- Set appropriate deployment target (iOS 13.0+)
- Configure signing and capabilities
- Set up app icons and launch screens

### 2. App Store Preparation
- Test on physical devices
- Verify all navigation flows work
- Check accessibility compliance
- Prepare app store metadata

## Contributing

### 1. Code Review Process
1. Create feature branch
2. Implement changes
3. Add tests
4. Submit pull request
5. Address review feedback

### 2. Commit Guidelines
- Use descriptive commit messages
- Reference issue numbers
- Keep commits focused and atomic

### 3. Pull Request Template
- Describe the changes
- Include testing instructions
- List any breaking changes
- Add screenshots if UI changes

## Resources

### Documentation
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Swift Package Manager](https://swift.org/package-manager/)
- [iOS App Architecture](https://developer.apple.com/design/human-interface-guidelines/ios/overview/architecture/)

### Tools
- Xcode (IDE)
- Simulator (Testing)
- Instruments (Performance)
- Accessibility Inspector (Accessibility)

This development guide should help you get started with contributing to the ScalablePackageNavigation project. For additional questions, please refer to the project documentation or create an issue in the repository. 