//
//  AppDelegate.swift
//  SDK Tester QA1
//
//  Created by Andrew Little on 7/13/17.
//  Copyright © 2017 Andrew Little. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    struct PushConstants {
        static let AppID_Debug = "192a5b71-caeb-45d4-80c6-c8eb7e43b14a"
        static let AccessToken_Debug = "yk2mzj45cdj9qegz6ffmpvdh"
        static let AppID_Prod = "6c4290f0-4fe3-4553-98eb-b36a16e423c0"
        static let AccessToken_Prod = "5xdtr6zasybvvn2zrb4eue9f"
    }
    
    
    //UI Testing Flags used for automation tests
    var CLEAR_ALL_DATA = false
    var CREATE_TEST_DATA_A = false
    var CREATE_TEST_DATA_B = false
    
    var window: UIWindow?
    var localNotificationFromLaunch: UNNotificationRequest?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.prepareToLaunchAddEntryScreenIfUserTappedLocalNotification(launchOptions)
        
        //Used ONLY for UI testing
        if ProcessInfo.processInfo.arguments.contains("CLEAR_ALL_DATA") {
            self.CLEAR_ALL_DATA = true
        }
        
        if ProcessInfo.processInfo.arguments.contains("CREATE_TEST_DATA_A") {
            self.CREATE_TEST_DATA_A = true
        }
        
        if ProcessInfo.processInfo.arguments.contains("CREATE_TEST_DATA_B") {
            self.CREATE_TEST_DATA_B = true
        }
        
        //Use Marketing Cloud for push notififcations
        AppDelegate.setupRemotePushNotifications(launchOptions: launchOptions)
        
        ETPush.pushManager()?.addAttributeNamed("Application Version", value: AppDelegate.appVersion())
        ETPush.pushManager()?.addAttributeNamed("Dog Name", value: "Ralph")
        
        return true
    }
    
    
    private class func setupRemotePushNotifications(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        var appID = PushConstants.AppID_Prod
        var accessToken = PushConstants.AccessToken_Prod
        
        #if DEBUG
            appID = PushConstants.AppID_Debug
            accessToken = PushConstants.AccessToken_Debug
            ETPush.pushManager()?.addTag("DEV BUILD")
        #else
            ETPush.pushManager()?.addTag("PROD BUILD")
        #endif
        do {
            try ETPush.pushManager()?.configureSDK(withAppID: appID, andAccessToken: accessToken, withAnalytics: true, andLocationServices: false, andProximityServices: false, andCloudPages: true, withPIAnalytics: true)
        } catch {

        }
        
        let notificationSettings = UIUserNotificationSettings(types: [UIUserNotificationType.badge, UIUserNotificationType.sound, UIUserNotificationType.alert], categories: nil)
        ETPush.pushManager()?.register(notificationSettings)
        ETPush.pushManager()?.registerForRemoteNotifications()
        ETPush.pushManager()?.applicationLaunched(options: launchOptions)
    }
    
    private func prepareToLaunchAddEntryScreenIfUserTappedLocalNotification(_ launchOptions: [AnyHashable: Any]?) {
        
        if launchOptions != nil {
            //Save the local notification for later as notw is not the right time to launch a view - app isn't ready
            self.localNotificationFromLaunch = launchOptions!["UIApplicationLaunchOptionsLocalNotificationKey"] as? UNNotificationRequest
        }
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        ETPush.pushManager()?.register(notificationSettings)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        ETPush.pushManager()?.applicationDidFailToRegisterForRemoteNotificationsWithError(error)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        ETPush.pushManager()?.registerDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // inform the JB4ASDK that the device received a remote notification
        ETPush.pushManager()?.handleNotification(userInfo, for: application.applicationState)
        completionHandler(UIBackgroundFetchResult.noData)
        AppDelegate.printDictionaryAsJson(dictionary: userInfo)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    class func printDictionaryAsJson(dictionary: [AnyHashable : Any]) {
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: dictionary,
            options: []) {
            let theJSONText = String(data: theJSONData,
                                     encoding: .ascii)
            print("JSON string = \(theJSONText!)")
        }
    }
    
    class func appVersion() -> String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return "0.0"
        }
        
        return version
    }
}
