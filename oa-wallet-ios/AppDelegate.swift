//
//  AppDelegate.swift
//  oa-wallet-ios
//
//  Created by Tan Cher Shen on 2/12/22.
//

import UIKit
import UniformTypeIdentifiers

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window:UIWindow?
    var tabBarController: UITabBarController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        if let tabBarController = self.tabBarController {
            window?.rootViewController = tabBarController
            window?.makeKeyAndVisible()
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let navigationController = tabBarController?.viewControllers?.first as? UINavigationController {
            if let walletVC = navigationController.viewControllers.first as? WalletViewController {
                tabBarController?.selectedIndex = 0
                guard UTType(filenameExtension: url.pathExtension) == .oa else { return false }
                walletVC.presentImportOptions(url: url)
            }
        }
        
        return true
    }
}

