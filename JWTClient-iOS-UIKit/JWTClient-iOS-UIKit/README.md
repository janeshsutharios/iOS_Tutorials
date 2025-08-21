# JWTClient-UIKit (OperationQueue)

A UIKit variant of the SwiftUI app that fetches Dashboard data using OperationQueue managers.

Reference: https://developer.apple.com/documentation/foundation/operationqueue

## Structure
- OperationQueues/
  - AsynchronousOperation.swift: Async Operation base.
  - DashboardOperations.swift: Endpoint operations and managers.
- UIKitApp/
  - AppDelegate.swift, SceneDelegate.swift, ViewController.swift

## Config
This app reuses `AppConfig.load` to read `config.dev.json`, `config.staging.json`, `config.prod.json` from the bundle. Ensure these files are included in the UIKit target’s resources.

## Run
- Open the Xcode workspace.
- Add a new iOS App target (UIKit) if not already present, and include files inside `JWTClient-UIKit`.
- Run on simulator or device.

## Usage
- Tap "Fetch Concurrent" to run parallel endpoint requests.
- Tap "Fetch Sequential" to run them one-by-one.
