//
//  AppDelegate.swift
//  Challonge
//
//  Created by Ashley Ng on 12/1/18.
//  Copyright © 2018 AshleyNg. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import Keys
import Instabug

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        window.rootViewController = UINavigationController(rootViewController: LoginViewController())
        
        self.window = window
        
        Fabric.with([Crashlytics.self, Answers.self])
        
        let keys = ChallongeKeys()
        let instabugKey = isRunningLive() ? keys.instabugLive : keys.instabugBeta
        Instabug.start(withToken: instabugKey, invocationEvents: [.none])
        return true
    }
    
    func isRunningLive() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        let isRunningTestFlightBeta  = (Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt")
        let hasEmbeddedMobileProvision = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil
        if (isRunningTestFlightBeta || hasEmbeddedMobileProvision) {
            return false
        } else {
            return true
        }
        #endif
    }
}

