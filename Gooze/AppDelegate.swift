//
//  AppDelegate.swift
//  Gooze
//
//  Created by Yussel on 10/21/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit
import CoreData
import SwiftyBeaver

let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        initialSetup()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        // self.saveContext()
    }

    // MARK: - Gooze Initial Setup
    
    func initialSetup() {
        GZEAppConfig.load()
        setUpLogs()
        setUpInitialController()

        // TODO: Move to a service
        // Override point for customization after application launch.
        UINavigationBar.appearance().barTintColor = GZEConstants.Color.mainBackground
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        UINavigationBar.appearance().isTranslucent = false

        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        UINavigationBar.appearance().shadowImage = UIImage()

        // UITextField.appearance().backgroundColor = .black
        // UITextField.appearance().textColor = .white
        // UITextField.appearance().tintColor = UIColor(red: 44/255, green: 198/255, blue: 159/255, alpha: 1)
    }
    
    func setUpLogs() {
        // SwiftyBearer cloud
        let platform = SBPlatformDestination(appID: GZEAppConfig.logAppID,
                                             appSecret: GZEAppConfig.logAppSecret,
                                             encryptionKey: GZEAppConfig.logAppKey)

        if (GZEAppConfig.logAppID.isEmpty) {
            NSLog("LogAppID configuration is empty. Platform logging will be disabled.")
        } else {
            log.addDestination(platform)
            NSLog("Added logging Platform destination. AppID: " + GZEAppConfig.logAppID)
        }

        // add log destinations.
        if GZEAppConfig.environment == .debug {
            log.addDestination(ConsoleDestination())
            NSLog("Added logging Console destination")
        }

        for destination in log.destinations {
            switch GZEAppConfig.logLevel {
            case "verbose":
                destination.minLevel = .verbose
            case "debug":
                destination.minLevel = .debug
            case "info":
                destination.minLevel = .info
            case "warning":
                destination.minLevel = .warning
            default:
                destination.minLevel = .error
            }
            destination.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M"

            // FILTERS
            //destination.minLevel = .error
            //let filter1 = Filters.Path.contains("View", minLevel: .debug)
            //destination.addFilter(filter1)
        }

        log.debug("Log level: " + GZEAppConfig.logLevel)
    }

    func setUpInitialController() {
        if
            let navController = window?.rootViewController as? UINavigationController,
            let loginController = navController.viewControllers.first as? GZELoginViewController {

            // Set up initial view model
            loginController.viewModel = GZELoginViewModel(GZEUserApiRepository())
        }
    }
}

