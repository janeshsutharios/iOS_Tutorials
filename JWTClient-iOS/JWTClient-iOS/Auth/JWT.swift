import Foundation

struct JWT {
    // skew means if we want to reduce the token time from backend,
    // Example: let sat 15 min is set from backend & if you set skew as 60 then 15-1 = 14 min.
    static func isExpired(_ token: String, skew: TimeInterval = 0) -> Bool {
        guard let payload = decodePayload(token),
              let exp = payload["exp"] as? TimeInterval else { return true } // safer: treat unknown as expired
        let expiry = Date(timeIntervalSince1970: exp)
        
        AppLogger.log("⏳ Token expiry: \(expiry.toGSTString()) | Current: \(Date().toGSTString())")
        AppLogger.log("⏳ addingTimeInterval: \(expiry.addingTimeInterval(-skew).toGSTString())")
        return Date() >= expiry.addingTimeInterval(-skew)
    }

    
    static func decodePayload(_ token: String) -> [String: Any]? {
        let parts = token.split(separator: ".")
        guard parts.count >= 2 else { return nil }
        var base64 = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padding = 4 - base64.count % 4
        if padding < 4 { base64 += String(repeating: "=", count: padding) }
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json
    }
}
