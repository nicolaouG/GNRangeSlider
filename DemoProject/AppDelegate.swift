//
//  AppDelegate.swift
//  DemoProject
//
//  Created by george on 30/04/2020.
//  Copyright © 2020 George Nicolaou. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 13.0, *) {
        } else {
            let rootVC = UINavigationController(rootViewController: DemoViewController())
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = rootVC
            window?.makeKeyAndVisible()
        }
        return true
    }
}

