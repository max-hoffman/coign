//
//  AppDelegate.swift
//  Coign
//
//  Created by Maximilian Hoffman on 9/3/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FBSDKCoreKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //MARK: - Properties
    var loginStoryboard: UIStoryboard?
    var mainAppStoryboard: UIStoryboard?
    var window: UIWindow?
    static let defaults = UserDefaults()
    
    //MARK: - Handle App Entry
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //connect to Firebase
        
        #if DEVELOPMENT
            let filePath = Bundle.main.path(forResource: "GoogleService-Dev-Info", ofType:"plist")
            let options = FIROptions(contentsOfFile:filePath)
            FIRApp.configure(with: options!)
            print("debug ran")
        #else
            let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType:"plist")
            let options = FIROptions(contentsOfFile:filePath)
            FIRApp.configure(with: options!)
            print("else rans")
        #endif
        
        //connect keyboard manager
        IQKeyboardManager.sharedManager().enable = true
        
        //make status bar text white
        UIApplication.shared.statusBarStyle = .lightContent
        
        //bypass login screen if user credential exists
        self.checkForAutoLogin()
        
        // Override point for customization after application launch.
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    //tells the application what to do after we grant authorization to use it
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    //MARK: - Handle app exit
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }

  }

//MARK: - Auto-login extension
private extension AppDelegate{
    func checkForAutoLogin() {
        //TODO: Remove memory cycles - might have already done that by making the storyboard referenecs optional
        //MARK: - rootVC is being set twice somehow; viewdidload is being called twice
        //Bypassed using segues; just used the rootViewController method
        self.loginStoryboard = UIStoryboard(name: Storyboard.Login.rawValue, bundle: .main)
        self.mainAppStoryboard = UIStoryboard(name: Storyboard.MainApp.rawValue, bundle: .main)
        let currentUser = FIRAuth.auth()?.currentUser
        
        if currentUser != nil {
            self.window?.rootViewController = self.mainAppStoryboard?.instantiateViewController(withIdentifier: "RevealVC")
            print("already logged in")
            
        }else {
            self.window?.rootViewController = self.loginStoryboard?.instantiateViewController(withIdentifier: "Login VC")
            print("need to login")
        }
    }
}
