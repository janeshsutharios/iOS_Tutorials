import Foundation

enum AppError: LocalizedError, Equatable {
    case invalidURL
    case decodingFailed
    case unauthorized
    case invalidCredentials
    case tokenRefreshFailed
    case missingRefreshToken
    case network(URLError.Code)
    case server(status: Int)
    case timeout
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "We couldn't reach the server."
        case .decodingFailed: return "Unexpected response from server."
        case .unauthorized: return "Your session expired. Please log in again."
        case .invalidCredentials: return "Invalid username or password."
        case .tokenRefreshFailed: return "Couldn't refresh your session."
        case .missingRefreshToken: return "You're signed out. Please log in."
        case .network(let code): return "Network error (\(code.rawValue)). Check your connection."
        case .server(let status): return "Server error (\(status)). Please try again."
        case .timeout: return "The request timed out. Please try again."
        case .unknown(let msg): return msg
        }
    }
}
