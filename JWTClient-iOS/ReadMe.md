Perfect, let’s break this down step by step. I’ll explain it in plain English first, then show you **Swift examples** so you can connect it with your iOS app. 🚀

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

# 👨‍💻 4. Swift Example – Token Handling

```swift
import Foundation

actor AuthService {
    private var accessToken: String?
    private var refreshToken: String?
    
    // 🔹 Get valid Access Token
    func validAccessToken() async throws -> String {
        if let token = accessToken, !JWT.isExpired(token) {
            return token
        }
        // expired → refresh
        try await refreshIfNeeded()
        if let token = accessToken { return token }
        throw AppError.unauthorized
    }
    
    // 🔹 Refresh token flow
    private func refreshIfNeeded() async throws {
        guard let refreshToken else { throw AppError.unauthorized }
        
        let url = URL(string: "https://api.example.com/auth/refresh")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw AppError.network }
        
        switch httpResponse.statusCode {
        case 200:
            let tokens = try JSONDecoder().decode(TokenResponse.self, from: data)
            accessToken = tokens.access
            self.refreshToken = tokens.refresh
        case 401:
            throw AppError.unauthorized
        default:
            throw AppError.server
        }
    }
}

struct TokenResponse: Decodable {
    let access: String
    let refresh: String
}

enum AppError: Error {
    case unauthorized
    case network
    case server
}

struct JWT {
    static func isExpired(_ token: String, skew: TimeInterval = 60) -> Bool {
        guard let payload = decodePayload(token),
              let exp = payload["exp"] as? TimeInterval else { return true }
        
        let expiry = Date(timeIntervalSince1970: exp)
        return Date().addingTimeInterval(skew) >= expiry
    }
    
    private static func decodePayload(_ token: String) -> [String: Any]? {
        let parts = token.split(separator: ".")
        guard parts.count == 3 else { return nil }
        
        let payloadData = Data(base64Encoded: String(parts[1]).padding(toLength: ((parts[1].count+3)/4)*4, withPad: "=", startingAt: 0))
        guard let data = payloadData else { return nil }
        return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    }
}
```

---

# ⚙️ 5. How to Use in API Calls

```swift
func fetchDashboardData(auth: AuthService) async throws -> DashboardData {
    let token = try await auth.validAccessToken()
    
    var request = URLRequest(url: URL(string: "https://api.example.com/dashboard")!)
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
        throw AppError.network
    }
    
    switch httpResponse.statusCode {
    case 200:
        return try JSONDecoder().decode(DashboardData.self, from: data)
    case 401:
        // Access token expired & refresh failed
        throw AppError.unauthorized
    default:
        throw AppError.server
    }
}
```

---

# 🧠 Key Takeaways

* **Access Token** = short-lived, sent in headers.
* **Refresh Token** = long-lived, used to get new access tokens.
* **JWT** = self-contained access token (with expiry).
* **HTTP 401** = refresh or re-login.
* Always store tokens **securely** in **Keychain** (not UserDefaults).

---
