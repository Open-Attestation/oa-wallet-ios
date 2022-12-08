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
    var walletVC: WalletViewController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        walletVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        if let walletVC = self.walletVC {
            let navigationController = UINavigationController(rootViewController: walletVC)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard UTType(filenameExtension: url.pathExtension) == .oa else { return false }
        walletVC?.presentImportOptions(url: url)
        
        return true
    }
}

