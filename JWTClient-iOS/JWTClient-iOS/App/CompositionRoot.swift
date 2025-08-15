import Foundation

struct AppContainer {
    let config: AppConfig
    let http: HTTPClientProtocol
    let tokenStore: TokenStore
    let authService: AuthService
    let api: APIService
    
    static func make(current: Environment = AppConfig.overrideEnvironment ?? .dev) -> AppContainer {
        let cfg = AppConfig.load(for: current)
        let http = HTTPClient(timeout: cfg.timeoutSeconds)
        let store = KeychainTokenStore()
        let auth = AuthService(config: cfg, http: http, store: store)
        let api = APIService(config: cfg, http: http)
        return .init(config: cfg, http: http, tokenStore: store, authService: auth, api: api)
    }
}
