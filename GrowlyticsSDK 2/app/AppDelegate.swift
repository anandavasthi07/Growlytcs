//
//  AppDelegate.swift
//  app
//
//  Created by Pradeep Singh on 04/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import UIKit
import Growlytics
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.registerForPushNotifications()
        
        // Register Growlytics Callbacks
        LifeCycleCallback.shared.register(application: application)

        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func registerForPushNotifications() {
        
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] granted, error in
                
                print("Permission granted: \(granted)")
                guard granted else { return }
                self?.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}

//MARK: Implemented UIApplicationDelegate
extension AppDelegate {
    
    //MARK: GET DEVICE APNS TOKEN
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        debugPrint("Device Token: \(token)")
        APNSMessagingService.shared.setupAPNSMessagingWith(token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("Failed to register: \(error)")
    }
    
    
    //MARK: GET UNIVERSAL LINKS
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        debugPrint("APP:", app)
        debugPrint("URL:", url)
        debugPrint("Options:", options)
        return true
    }
    
    public func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                            restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        // handler for Universal Links
        
        debugPrint("UserActivity:", userActivity)
        
        // 1
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                return false
        }
        
        // 3
        if let webpageUrl = URL(string: "http://rw-universal-links-final.herokuapp.com") {
            application.open(webpageUrl)
            return false
        }
        
        return false
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        debugPrint("UserInfo:", userInfo)

    }
}
