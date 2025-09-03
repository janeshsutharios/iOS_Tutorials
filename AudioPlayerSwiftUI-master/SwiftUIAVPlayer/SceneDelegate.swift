//
//  SceneDelegate.swift
//  SwiftUIAVPlayer
//
//  Created by Jon Gary on 7/13/20.
//  Copyright © 2020 Jon Gary. All rights reserved.
//

import AVFoundation
import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        guard let audioFileURL = Bundle.main.url(forResource: "LongTeaTime", withExtension: "mp3") else {
//            fatalError("missing mp3")
//        }
        let audioUrl = URL(string: "https://2021.dming2021.xyz/bollywood%20mp3/radhe%20(2021)3/03%20-%20Radhe%20Title%20Track%20(128%20Kbps).mp3")!
        let playerItem = AVPlayerItem(url: audioUrl)
        let player = PlayerFrameWork(avPlayer: AVPlayer(playerItem: playerItem))
        let contentView = ContentView(player: player)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}

