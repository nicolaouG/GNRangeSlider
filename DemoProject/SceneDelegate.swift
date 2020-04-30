//
//  SceneDelegate.swift
//  DemoProject
//
//  Created by george on 30/04/2020.
//  Copyright © 2020 George Nicolaou. All rights reserved.
//

import UIKit
import SwiftUI

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow? {
        didSet {
            let appDelegate = AppDelegate()
            appDelegate.window = window
        }
    }


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UINavigationController(rootViewController: DemoViewController())
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}

