//
//  SceneDelegate.swift
//  MVVMStateManagement
//
//  Created by JANESH SUTHAR on 13/06/25.
//

import UIKit
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let cartService = CartService()
        let cartViewModel = CartViewModel(cartService: cartService)
        let cartVC = CartViewController(viewModel: cartViewModel, cartService: cartService)
        let navVC = UINavigationController(rootViewController: cartVC)

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navVC
        self.window = window
        window.makeKeyAndVisible()
    }
}
