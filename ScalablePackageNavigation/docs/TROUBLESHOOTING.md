# Troubleshooting Guide

This guide helps you resolve common issues when working with the ScalablePackageNavigation project.

## 🚨 Build Issues

### Package Resolution Errors

**Error**: `Could not resolve package dependencies`

**Solutions**:
1. **Clean and rebuild**:
   ```bash
   # In Xcode: Product → Clean Build Folder (Cmd + Shift + K)
   # Then rebuild (Cmd + R)
   ```

2. **Reset package cache**:
   ```bash
   # In Xcode: File → Packages → Reset Package Caches
   ```

3. **Check Package.swift files**:
   - Verify all `Package.swift` files have correct dependencies
   - Ensure path references are correct (`../AppRouter`)

### Swift Version Compatibility

**Error**: `Swift version 6.2 is required`

**Solutions**:
1. **Update Xcode** to latest version
2. **Check Swift version** in project settings
3. **Update Package.swift** files:
   ```swift
   // swift-tools-version: 6.2
   ```

### Missing Imports

**Error**: `Cannot find 'AppRouter' in scope`

**Solutions**:
1. **Add import statement**:
   ```swift
   import AppRouter
   ```

2. **Check package dependencies** in `Package.swift`:
   ```swift
   dependencies: [
       .package(name: "AppRouter", path: "../AppRouter")
   ]
   ```

3. **Verify target dependencies**:
   ```swift
   targets: [
       .target(
           name: "YourTarget",
           dependencies: ["AppRouter"]
       )
   ]
   ```

## 🧭 Navigation Issues

### Navigation Not Working

**Problem**: Button taps don't navigate to expected screen

**Solutions**:
1. **Check router injection**:
   ```swift
   @EnvironmentObject var router: AppRouter
   ```

2. **Verify route exists** in `Route` enum:
   ```swift
   public enum Route {
       case dashboard
       case cart
       case summary
       // Add your route here
   }
   ```

3. **Check navigation destination** in main app:
   ```swift
   switch route {
   case .yourRoute:
       YourView()
           .environmentObject(router)
   }
   ```

4. **Verify navigation call**:
   ```swift
   router.path.append(.yourRoute)
   ```

### Navigation Stack Issues

**Problem**: Navigation stack not clearing or behaving unexpectedly

**Solutions**:
1. **Clear entire stack**:
   ```swift
   router.path = []
   ```

2. **Remove specific routes**:
   ```swift
   router.path.removeLast()
   ```

3. **Check for navigation loops**:
   - Ensure routes don't navigate to themselves
   - Verify navigation logic in buttons

### Back Button Not Working

**Problem**: Back button doesn't appear or function

**Solutions**:
1. **Check NavigationStack setup**:
   ```swift
   NavigationStack(path: $router.path) {
       // Your content
   }
   ```

2. **Verify navigationDestination**:
   ```swift
   .navigationDestination(for: Route.self) { route in
       // Your destination views
   }
   ```

3. **Hide back button if needed**:
   ```swift
   .navigationBarBackButtonHidden()
   ```

## 🔄 State Management Issues

### State Not Updating

**Problem**: UI doesn't reflect changes to router state

**Solutions**:
1. **Check @Published properties**:
   ```swift
   @Published public var cartItems: [String] = []
   ```

2. **Verify @EnvironmentObject**:
   ```swift
   @EnvironmentObject var router: AppRouter
   ```

3. **Ensure main thread updates**:
   ```swift
   DispatchQueue.main.async {
       router.cartItems.append("New Item")
   }
   ```

### State Persistence Issues

**Problem**: State resets when navigating

**Solutions**:
1. **Check router lifecycle**:
   - Router should be created once at app level
   - Use `@StateObject` in main app

2. **Verify environment object injection**:
   ```swift
   .environmentObject(router)
   ```

### Cart Items Not Showing

**Problem**: Cart view shows empty even after adding items

**Solutions**:
1. **Check item addition logic**:
   ```swift
   router.cartItems.append("Pizza")
   ```

2. **Verify ForEach binding**:
   ```swift
   ForEach(router.cartItems, id: \.self) { item in
       Text(item)
   }
   ```

3. **Add debug prints**:
   ```swift
   print("Cart items: \(router.cartItems)")
   ```

## 🎨 UI Issues

### Views Not Rendering

**Problem**: Views appear blank or don't show content

**Solutions**:
1. **Check view structure**:
   ```swift
   public var body: some View {
       VStack {
           Text("Hello World")
       }
   }
   ```

2. **Verify public access**:
   ```swift
   public struct YourView: View {
       public init() {}
       public var body: some View
   }
   ```

3. **Check for layout issues**:
   - Add background colors for debugging
   - Verify frame sizes

### Layout Problems

**Problem**: UI elements not positioned correctly

**Solutions**:
1. **Add spacing**:
   ```swift
   VStack(spacing: 20) {
       // Your content
   }
   ```

2. **Use padding**:
   ```swift
   .padding()
   ```

3. **Check frame constraints**:
   ```swift
   .frame(maxWidth: .infinity, maxHeight: .infinity)
   ```

## 🔧 Package Issues

### Package Not Found

**Error**: `No such module 'YourPackage'`

**Solutions**:
1. **Check package structure**:
   ```
   YourPackage/
   ├── Package.swift
   └── Sources/
       └── YourPackage/
           └── YourPackage.swift
   ```

2. **Verify Package.swift**:
   ```swift
   let package = Package(
       name: "YourPackage",
       products: [
           .library(
               name: "YourPackage",
               targets: ["YourPackage"]
           ),
       ],
       targets: [
           .target(
               name: "YourPackage"
           ),
       ]
   )
   ```

3. **Add to main app dependencies**:
   - Add package reference in Xcode
   - Import in your Swift files

### Package Dependencies

**Error**: `Dependency resolution failed`

**Solutions**:
1. **Check dependency paths**:
   ```swift
   dependencies: [
       .package(name: "AppRouter", path: "../AppRouter")
   ]
   ```

2. **Verify target dependencies**:
   ```swift
   targets: [
       .target(
           name: "YourTarget",
           dependencies: ["AppRouter"]
       )
   ]
   ```

3. **Update package cache**:
   - File → Packages → Update to Latest Package Versions

## 🐛 Runtime Issues

### App Crashes

**Problem**: App crashes on launch or during navigation

**Solutions**:
1. **Check console logs** for specific error messages
2. **Verify all required properties** are initialized
3. **Check for force unwrapping** (`!`) and replace with safe unwrapping
4. **Add error handling**:
   ```swift
   guard let router = router else {
       return Text("Router not available")
   }
   ```

### Memory Issues

**Problem**: App becomes slow or crashes due to memory

**Solutions**:
1. **Check for retain cycles** in closures
2. **Use weak references** where appropriate
3. **Monitor memory usage** in Xcode Instruments
4. **Avoid storing large objects** in router state

## 🔍 Debugging Tips

### Add Debug Prints

```swift
print("Navigation path: \(router.path)")
print("Cart items: \(router.cartItems)")
print("Current route: \(route)")
```

### Use Xcode Debugger

1. **Set breakpoints** in navigation methods
2. **Inspect router state** in debugger
3. **Use view hierarchy debugger** for UI issues
4. **Check memory graph** for retain cycles

### Enable Debug Logging

```swift
#if DEBUG
print("Debug: \(message)")
#endif
```

## 📞 Getting Help

If you're still experiencing issues:

1. **Check the documentation**:
   - `README.md` - Project overview
   - `docs/ARCHITECTURE.md` - Technical details
   - `docs/API_REFERENCE.md` - API documentation

2. **Search existing issues** in the repository

3. **Create a new issue** with:
   - Clear description of the problem
   - Steps to reproduce
   - Error messages
   - Your environment (Xcode version, iOS version)

4. **Provide minimal reproduction**:
   - Create a simple test case
   - Include relevant code snippets
   - Describe expected vs actual behavior

## 🎯 Prevention Tips

### Best Practices

1. **Always use type-safe navigation** with the `Route` enum
2. **Test navigation flows** after making changes
3. **Keep packages focused** on single responsibilities
4. **Use consistent naming** conventions
5. **Add error handling** for edge cases
6. **Test on different devices** and iOS versions

### Code Review Checklist

- [ ] All imports are present
- [ ] Router is properly injected
- [ ] Routes are added to enum
- [ ] Navigation destinations are handled
- [ ] State updates use @Published
- [ ] UI updates are on main thread
- [ ] No force unwrapping
- [ ] Error handling is in place

This troubleshooting guide should help you resolve most common issues. If you continue to experience problems, please refer to the other documentation or create an issue in the repository. 