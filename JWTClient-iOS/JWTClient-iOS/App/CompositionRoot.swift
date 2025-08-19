import Foundation

// MARK: - Dependency Injection Container
// AppContainer is responsible for creating and managing all application services
// This follows the Dependency Injection pattern for better testability and modularity
@MainActor
struct AppContainer {
    // MARK: - Service Dependencies
    let config: AppConfig           // Environment-specific configuration
    let http: HTTPClientProtocol   // Network layer (protocol for testing)
    let tokenStore: TokenStore     // Secure token storage (Keychain in production)
    let authService: AuthService   // Authentication state management
    let api: APIService            // API endpoint coordination
    
    // MARK: - Factory Method
    // Creates and configures all services with proper dependencies
    // Environment can be overridden for testing or different deployment targets
    static func make(current: Environment = AppConfig.overrideEnvironment ?? .dev) -> AppContainer {
        // 1. Load environment-specific configuration
        let cfg = AppConfig.load(for: current)
        
        // 2. Create network layer with configured timeout
        let http = HTTPClient(timeout: cfg.timeoutSeconds)
        
        // 3. Create secure token storage (Keychain for production, InMemory for tests)
        let store = KeychainTokenStore()
        
        // 4. Create auth service with dependencies
        let auth = AuthService(config: cfg, http: http, store: store)
        
        // 5. Create API service with network layer
        let api = APIService(config: cfg, http: http)
        
        // 6. Return configured container
        return .init(config: cfg, http: http, tokenStore: store, authService: auth, api: api)
    }
}
