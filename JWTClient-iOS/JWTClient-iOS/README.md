# JWTClientPro

A production-grade SwiftUI JWT client demonstrating:
- Secure token storage in **Keychain**
- **Dependency Injection** (no singletons)
- Token **expiration & auto-refresh**
- Structured **error handling** + user-friendly messages
- Config management with **dev/staging/prod** JSON
- SwiftUI UX: loading states, skeletons, pull-to-refresh, validation
- Async/await timeout, cancellation, **retry with exponential backoff**
- Testability with protocols and mocks

## Setup

1. Create a new **iOS App (SwiftUI)** in Xcode named `JWTClientPro`, or drag these files into an existing project.
2. Add the `Config/*.json` files to the app **target** (copy if needed).
3. Ensure **Info.plist** contains the `NSAppTransportSecurity` section provided.
4. Update `Config/config.dev.json` `baseURL` to your backend host.
5. Build & Run (iOS 15+).

## Environments

Switch the `current` environment in `App/CompositionRoot.swift` or select via `AppConfig.overrideEnvironment`.

## Endpoints expected

- `POST /login` → `{ accessToken, refreshToken }`
- `POST /refresh` → `{ accessToken }`
- `POST /logout` (body: `{ token: <refreshToken> }`)
- `GET /profile`, `GET /restaurants`, `GET /festivals`, `GET /users`
