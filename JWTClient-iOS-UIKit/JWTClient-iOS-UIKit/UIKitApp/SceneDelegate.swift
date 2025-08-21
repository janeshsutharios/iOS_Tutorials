import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        
        // MARK: - Conditional Navigation
        // Routes to Dashboard when authenticated, Login when not
        let container = AppContainer.make()
        if container.authService.isAuthenticated {
            window.rootViewController = ViewController()
        } else {
            let loginVC = LoginViewController(auth: container.authService)
            loginVC.onSuccess = { [weak self] in
                let dashboardVC = ViewController()
                self?.window?.rootViewController = dashboardVC
            }
            window.rootViewController = loginVC
        }
        
        self.window = window
        window.makeKeyAndVisible()
    }
}


