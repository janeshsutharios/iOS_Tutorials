# JWTClient-iOS 🔐   ![Swift](https://img.shields.io/badge/Swift-6.1-orange.svg) ![Platform](https://img.shields.io/badge/iOS-16+-blue.svg)  ![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)
---

# 🔑 1. What are Access Token, Refresh Token & JWT?

### **Access Token**

* A **short-lived key** (usually JWT) given to the client after login.
* Sent with every API request (`Authorization: Bearer <token>`).
* Proves the user is authenticated.
* Expiry: Usually **5–15 minutes**.

### **Refresh Token**

* A **long-lived key** (not sent with every request).
* Stored securely on the device (e.g., Keychain in iOS).
* Used to **get a new Access Token** when it expires.
* Expiry: **Days, weeks, or months**.

### **JWT (JSON Web Token)**

* A **self-contained token** (looks like `xxxxx.yyyyy.zzzzz`).
* Contains **user info + expiry time** encoded in JSON.
* Can be **verified without hitting the server** (because it’s signed).

---

# 🔁 2. The Flow

1. User logs in → Backend returns **Access Token + Refresh Token**.
2. Client uses **Access Token** in requests.
3. If API returns **401 Unauthorized** → Access Token expired.
4. Client calls `/refresh` with the **Refresh Token**.
5. Backend issues a new **Access Token**.
6. If **Refresh Token is invalid/expired**, force **re-login**.

---

# 📡 3. Managing HTTP Codes

* **200 OK** → Everything fine.
* **401 Unauthorized** → Access Token invalid/expired.
* **403 Forbidden** → User doesn’t have permission (e.g., normal user hitting admin API).
* **500 Internal Server Error** → Server issue (retry later).

👉 The main one you’ll handle for JWT is **401 Unauthorized**.

---

A modern iOS client demonstrating secure JWT authentication, concurrent API calls, and Swift 6-ready architecture.

!<img width="390" height="844" alt="simulator_screenshot_1AAD5E33-F98E-490E-93F7-1E198942D05B" src="https://github.com/user-attachments/assets/3070fa86-e18e-4268-9ebb-53eebd93b829" />
 <!-- Add actual screenshot later -->

## Features ✨

- **Secure Authentication**  
  ✅ JWT token handling with automatic refresh  
  ✅ Keychain token storage  
  ✅ Login/logout flow  

- **Robust Networking**  
  ⚡️ Concurrent API calls with error aggregation  
  🔄 Sequential fallback mode  
  🛡️ Automatic retry with exponential backoff  

- **Modern Architecture**  
  🏗️ Protocol-oriented design for testability  
  🧵 Strict Swift 6 concurrency compliance  
  🗃️ Environment-based configuration  

## Technical Stack 🛠️

| Component          | Technology                          |
|--------------------|-------------------------------------|
| Language           |  (Swift 6 ready)                    |
| Concurrency        | async/await, Actors                 |
| Networking         | URLSession + Custom HTTPClient      |
| Dependency Mgmt    | Pure Swift (No third-party)         |
| Logging            | OSLog with unified system           |
| Security           | Keychain Services                   |

## Project Structure 📂

```
JWTClient-iOS/
├── App/                 # Core app infrastructure
│   ├── AppConfig.swift
│   ├── CompositionRoot.swift
│   └── JWTClientProApp.swift
├── Auth/                # Authentication flow
│   ├── AuthService.swift
│   ├── JWT.swift
│   └── KeychainTokenStore.swift
├── Networking/          # Network layer
│   ├── APIService.swift
│   ├── HTTPClient.swift
│   ├── AsyncCallsManage.swift
│   └── SyncCallManagement.swift
├── UI/                  # View layer
│   ├── DashboardView.swift
│   ├── LoginView.swift
│   └── ViewModifiers.swift
├── Utils/               # Utilities
│   └── Logger.swift
└── Config/              # Environment configs
    ├── config.dev.json
    ├── config.prod.json
    └── config.staging.json
```

## Key Design Patterns 🧩

1. **Protocol-Oriented DI**  
   ```swift
   protocol HTTPClientProtocol {
       func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
   }
   ```

2. **Concurrent Data Fetching**  
   ```swift
   await withTaskGroup(of: (String, Result<Any, Error>).self) { group in
       group.addTask { /* API call */ }
   }
   ```

3. **Token Refresh Coordination**  
   ```swift
   actor SingleFlight {
       private var inFlight: Task<Void, Error>?
       // ...
   }
   ```

## Getting Started 🚀

### Prerequisites
- Xcode 26+
- iOS 16+
- Swift 6.1+

### Installation
1. Clone the repository
   ```bash
   git clone https://github.com/yourusername/JWTClient-iOS.git
   ```
2. Open `JWTClientPro.xcodeproj`
3. Start local server from here https://github.com/janeshsutharios/REST_JWT_NODEJS_POC.git
```

## Testing 🧪

### Unit Tests
Run the test suite

### Key Test Cases
1. `AuthServiceTests` - Token refresh flow
2. `HTTPClientTests` - Network error handling
3. `DashboardViewModelTests` - Data aggregation

## Best Practices 🔍

1. **Thread Safety**
   - `@MainActor` for UI-related state
   - `nonisolated` for async entry points

2. **Error Handling**
   ```swift
   enum AppError: LocalizedError, Equatable, Sendable {
       case unauthorized
       // ...
   }
   ```

3. **Logging**
   ```swift
   AppLogger.network("Request started")
   AppLogger.error("Refresh failed", category: .auth)
   ```

## Future Improvements 📈

- [ ] Add SwiftUI Previews
- [ ] Add performance metrics


## Contributors 👥

- [Janesh Suthar](https://github.com/janeshsutharios)

## License 📄

MIT License - See [LICENSE](LICENSE) for details
```


---

# 🧠 Key Takeaways

* **Access Token** = short-lived, sent in headers.
* **Refresh Token** = long-lived, used to get new access tokens.
* **JWT** = self-contained access token (with expiry).
* **HTTP 401** = refresh or re-login.
* Always store tokens **securely** in **Keychain** (not UserDefaults).

---
