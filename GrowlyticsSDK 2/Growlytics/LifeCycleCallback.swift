//
//  LifeCycleCallback.swift
//  Growlytics
//
//  Created by Pradeep Singh on 06/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public class LifeCycleCallback : NSObject {
    
    public static let shared = LifeCycleCallback()
    
    fileprivate var registered : Bool = false
    
    @available(iOS 13.0, *)
    public func register(scene : UIScene) {
        self.register(scene: scene, growlyticsApiKey: nil)
    }
    
    @available(iOS 13.0, *)
    private func register(scene : UIScene?, growlyticsApiKey : String? ) {
        if (Config.getInstance().isDisable()) {
            Logger.instance.info(message: "Growlytics is disabled from config.");
            return
        }
    
        if (self.registered) {
            Logger.instance.info(message: "Lifecycle callbacks have already been registered");
            return
        }
        self.registered = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(onCreated), name:
            UIScene.willConnectNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onResume), name:
            UIScene.willEnterForegroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onPause), name:
            UIScene.willDeactivateNotification, object: nil)
        
        Logger.instance.info(suffix: "Application", message: "Lifecycle Callback successfully registered");
    }
    
    
    public func register(application : UIApplication) {
           self.register(application: application, growlyticsApiKey: nil);
    }
    
    private func register(application : UIApplication?, growlyticsApiKey : String? ) {
        if (Config.getInstance().isDisable()) {
            Logger.instance.info(message: "Growlytics is disabled from config.");
            return
        }
        
        if (application == nil) {
            Logger.instance.info(message: "Application instance is null/system API is too old");
            return
        }
        
        if (self.registered) {
            Logger.instance.info(message: "Lifecycle callbacks have already been registered");
            return
        }
        self.registered = true
        
        //Check the db for UDID
        
      
       // application?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(onCreated), name:
            UIApplication.didFinishLaunchingNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onResume), name:
            UIApplication.didBecomeActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onPause), name:
            UIApplication.didEnterBackgroundNotification, object: nil)
        
        Logger.instance.info(suffix: "Application", message: "Lifecycle Callback successfully registered");
    }
    
    @objc private func onCreated() {
        Logger.instance.debug(message: "On Created called")
        
        //To check device registration
        AppInstallReceiver.checkAppforUdid()
        
        //To check the app is installed
        AppInstallReceiver.checkAppInstalled()
        
        //  Analytics.getInstance().onActivityCreated()
        Logger.instance.debug(message: "On Created finished")
    }
    
    @objc private func onResume() {
        Logger.instance.debug(message: "On Resumed called")
        let queue = DispatchQueue.init(label: "scheduleQueueResumeFlush")
        queue.asyncAfter(deadline: .now() + 5.0, execute: {
            Analytics.getInstance().onActivityResumed()
        })
        Logger.instance.debug(message: "On Resumed finished")
    }
    
    @objc private func onPause() {
        Logger.instance.debug(message: "On Paused called")
        Analytics.getInstance().onActivityPaused()
        Logger.instance.debug(message: "On Paused finished")
    }
    
}

