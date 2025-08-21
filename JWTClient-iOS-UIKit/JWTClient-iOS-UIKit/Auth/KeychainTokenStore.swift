import Foundation
import Security

protocol TokenStore: Sendable {
    func save(accessToken: String?, refreshToken: String?) throws
    func load() throws -> (accessToken: String?, refreshToken: String?)
    func clear() throws
}

final class KeychainTokenStore: TokenStore {
    private let service = "com.example.JWTClientPro.tokens"
    private let account = "jwt"
    
    func save(accessToken: String?, refreshToken: String?) throws {
        let dict: [String:String?] = ["accessToken": accessToken, "refreshToken": refreshToken]
        let data = try JSONSerialization.data(withJSONObject: dict.compactMapValues { $0 }, options: [])
        try upsert(data: data)
    }
    
    func load() throws -> (accessToken: String?, refreshToken: String?) {
        guard let data = try read() else { return (nil, nil) }
        if let dict = try JSONSerialization.jsonObject(with: data) as? [String: String] {
            return (dict["accessToken"], dict["refreshToken"])
        }
        return (nil, nil)
    }
    
    func clear() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    private func upsert(data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            var addQuery = query
            addQuery[kSecValueData as String] = data
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else { throw NSError(domain: NSOSStatusErrorDomain, code: Int(addStatus)) }
        } else if status != errSecSuccess {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
    }
    
    private func read() throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess else { throw NSError(domain: NSOSStatusErrorDomain, code: Int(status)) }
        return (item as? Data)
    }
}
