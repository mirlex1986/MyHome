//
//  AppDelegate.swift
//  MyHome
//
//  Created by Aleksey Mironov on 21.09.2021.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = HomeViewController()
        window?.makeKeyAndVisible()
        
        return true
    }
}

