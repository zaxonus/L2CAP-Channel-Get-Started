//
//  AppDelegate.swift
//  L2CAPC
//
//  Created by Michel Bouchet on 2019/01/21.
//  Copyright © 2019 Michel Bouchet. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        #if ISPERIPHERAL
        let topVC = L2C_Peripheral_ViewController()
        #else // ISCENTRAL
        let topVC = L2C_Central_ViewController()
        #endif
        topVC.view.backgroundColor = UIColor.white
        window!.rootViewController = topVC
        window!.makeKeyAndVisible()
        return true
    }
}
