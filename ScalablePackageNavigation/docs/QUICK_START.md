# Quick Start Guide

Get up and running with ScalablePackageNavigation in under 5 minutes!

## 🚀 Quick Setup

### 1. Prerequisites
- Xcode 14.0+ installed
- iOS 13.0+ simulator or device

### 2. Clone and Open
```bash
git clone <repository-url>
cd ScalablePackageNavigation
open ScalablePackageNavigation.xcodeproj
```

### 3. Build and Run
1. Select a simulator (iPhone 14 recommended)
2. Press `Cmd + R` or click ▶️
3. App launches with Dashboard screen

## 🎯 What You'll See

The app demonstrates a simple pizza ordering flow:

1. **Dashboard** 🍕 - Main screen with "Add Pizza to Cart" button
2. **Cart** 🛒 - Shows items in cart with "Place Order" button  
3. **Order Summary** ✅ - Confirms order with "Go to Home" button

## 🔧 Key Concepts

### Navigation Flow
```
Dashboard → Add Item → Cart → Place Order → Summary → Home
```

### Architecture Overview
- **AppRouter**: Central navigation & state management
- **CartPackage**: Shopping cart functionality
- **OrderSummaryPackage**: Order processing
- **Main App**: Orchestrates all packages

### State Management
- Cart items are shared across all screens
- Navigation state is managed centrally
- Uses SwiftUI's `@EnvironmentObject` for dependency injection

## 💡 Try These Modifications

### Add a New Item Type
**File**: `ScalablePackageNavigation/AppViews/DashboardView.swift`

```swift
Button("Add Burger to Cart") {
    router.cartItems.append("Burger")
    router.path.append(.cart)
}
```

### Change Cart Display
**File**: `CartPackage/Sources/CartPackage/CartView.swift`

```swift
ForEach(router.cartItems, id: \.self) { item in
    Text("🍕 \(item)")  // Add emoji
        .font(.title2)
}
```

### Add Item Count
**File**: `CartPackage/Sources/CartPackage/CartView.swift`

```swift
Text("Items in cart: \(router.cartItems.count)")
    .font(.headline)
```

## 🐛 Common Issues

### Build Fails
- **Solution**: Clean build folder (`Cmd + Shift + K`) then rebuild
- **Cause**: Package dependencies need refresh

### Navigation Not Working
- **Solution**: Check that `@EnvironmentObject var router: AppRouter` is in your view
- **Cause**: Router not properly injected

### State Not Updating
- **Solution**: Ensure you're using `@Published` properties in AppRouter
- **Cause**: UI not observing state changes

## 📚 Next Steps

1. **Read the Architecture Documentation**: `docs/ARCHITECTURE.md`
2. **Explore the API Reference**: `docs/API_REFERENCE.md`
3. **Follow the Development Guide**: `docs/DEVELOPMENT_GUIDE.md`
4. **Add Your Own Features**: Create new packages following the existing pattern

## 🎉 You're Ready!

You now have a working understanding of the ScalablePackageNavigation project. The modular architecture makes it easy to add new features, and the centralized navigation system provides a clean, maintainable codebase.

Happy coding! 🚀 