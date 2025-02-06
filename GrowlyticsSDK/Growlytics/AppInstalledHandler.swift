//
//  AppInstalledHandler.swift
//  Growlytics
//
//  Created by Pradeep Singh on 15/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation
class AppInstalledHandler {
    
    private static var instance : AppInstalledHandler?
    private let config          : Config?
    private let eventQueue      : EventQueue?
    private let deviceInfo      : DeviceInfo?
    
    // Sqlite Helper & Syncing
    private let dbStorage       : SqliteHelper?
    
    // Async background processing variables
    let serialQueue = DispatchQueue.init(label: "AppInstalled")
    
    
   private init() {
        self.config     = Config.getInstance()
        self.dbStorage  = SqliteHelper.getInstance()
        self.eventQueue = EventQueue.getInstance()
        self.deviceInfo = DeviceInfo.getInstance()
    }

    static func getInstance()-> AppInstalledHandler {
        if (instance != nil) {
            Logger.instance.info(suffix: "getInstance", message: "AppInstalledHandler Instance is already initialized.")
            return instance!
        }

        // Initialize instance.
        instance = AppInstalledHandler()
        return instance!
    }
    
    /// This function will be called when app is installed and launched first time.
    func trackAppInstalledEvent() {
        // App install tracking
        var installReferrerMap = [String:Int](minimumCapacity: 8)
        
        self.serialQueue.async {
            Logger.instance.info(suffix: "App Install:", message: "Request received.")
            
            let strUrl = "test1=blah&test2=blahblah"
            
            let now:Int = Int(Date.currentTimeMillis / 1000)
            //noinspection Constant Conditions
            if installReferrerMap.keys.contains(strUrl) {
                if now - installReferrerMap[strUrl]! < 20{
                    Logger.instance.debug(suffix: "App Install", message: "Skipping install referrer due to duplicate within 20 seconds")
                    return
                }
            }
            
            installReferrerMap[strUrl] = now
            
            var appInstallAttributes = [String:Any]()
            appInstallAttributes["firstTime"] = true
            Analytics.getInstance().track(Constants.EVENT_APP_INSTALLED, appInstallAttributes)
        }
    }
}

