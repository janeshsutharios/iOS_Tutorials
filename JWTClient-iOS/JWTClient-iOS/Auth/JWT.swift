import Foundation

struct JWT {
    // for testing purpose I set it currently 5 seconds to expire token.
    static func isExpired(_ token: String, skew: TimeInterval = 5) -> Bool {
        guard let payload = decodePayload(token),
              let exp = payload["exp"] as? TimeInterval else { return false }
        let expiry = Date(timeIntervalSince1970: exp)
        return Date().addingTimeInterval(skew) >= expiry
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
