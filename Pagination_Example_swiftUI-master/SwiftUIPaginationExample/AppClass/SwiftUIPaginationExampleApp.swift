//
//  SwiftUIPaginationExampleApp.swift
//  SwiftUIPaginationExample
//
//  Created by Janesh Suthar on 19/08/21.
//

//import SwiftUI
//
//@available(iOS 14.0, *)
//@main
//struct SwiftUIPaginationExampleApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: ContentView())
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
