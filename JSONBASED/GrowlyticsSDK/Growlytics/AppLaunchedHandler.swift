//
//  AppLaunchedHandler.swift
//  Growlytics
//
//  Created by Pradeep Singh on 16/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation

class AppLaunchedHandler : NSObject {
    
    private static var instance : AppLaunchedHandler?
    private var config          : Config?
    private var eventQueue      : EventQueue?
    private var deviceInfo      : DeviceInfo?

    // Sqlite Helper & Syncing
    private var dbStorage      : JSONHelper?
    
    // Async background processing variables
    let serialQueue = DispatchQueue.init(label: "EventProcessor")
    
    private override init() {
        self.config     = Config.getInstance()
        self.dbStorage  = JSONHelper.getInstance()
        self.eventQueue = EventQueue.getInstance()
        self.deviceInfo = DeviceInfo.getInstance()
    }

    static func getInstance() -> AppLaunchedHandler{
        if (instance != nil) {
            Logger.instance.info(suffix: "App Launched Handler", message: "AppLaunchedHandler Instance is already initialized.")
            return instance!
        }

        // Initialize instance.
        instance = AppLaunchedHandler()
        return instance!
    }

    //MARK: Track App Launched Event
    // This method will create app launch if not created
    // It will also create a new session if session is expired or not present
    func handleAppLaunched( _ trafficSourceInfo: TrafficSourceInfo?, isFirstTime: Bool) {
        
        if (!isSessionExpired() && self.eventQueue!.appLaunchPushed) {
            Logger.instance.info(message: "SessionInfo Exists & App Launched has already been triggered. Will not trigger it.")
            return
        }
        
        self.serialQueue.async {
            self.synchronized(self){
                // Re-check if app launched event is already pushed.
                if (!self.isSessionExpired() && self.eventQueue!.appLaunchPushed) {
                    Logger.instance.info(message: "SessionInfo Exists & App Launched has already been triggered. Will not trigger it.")
                    return
                }
                Logger.instance.info(message: "Firing App Launched event")
                
                // Create session if expired
                Logger.instance.info(message: "Checking if session is expired, will create new if expired.")
                //self.createSessionIfExpired()
                
                // Build app launch event parameters
                Logger.instance.info(message: "Saving app launch event.")
                var appLaunchAttributes = [String:Any]()
                appLaunchAttributes["firstTime"] = isFirstTime
                Analytics.getInstance().track(Constants.EVENT_APP_LAUNCHED, appLaunchAttributes)
                self.eventQueue?.removeExpiredEventsFromDb()
            }
        }
    }
    
    // Update APNS Token
    func updateAPNSToken(_ token : String ) {
//        self.serialQueue.async {
//            Logger.instance.debug(suffix: "APNS Token Received:", message: token)
//
//            let event = EventModel()
//            event.eventType = .newToken
//            event.name = "New Token"
//            event.info = ["token":token]
//            event.eventTime = Int(Date.currentTimeMillis / 1000)
//
//            // Build json of attributes
//            let info = NSMutableDictionary()
//            info["token"] = token
//            event.info = info
//
//            Logger.instance.info(suffix: "APNS", message: "Adding event to queue => " + event.toString())
//            self.eventQueue?.addEventToQueue(event)
//        }
    }
    
    private func createSessionIfExpired() {
            if (self.isSessionExpired()) {
                Logger.instance.debug(message: "Session is expired, creating new one")
                let sessionId : String  = "\(Date.currentTimeMillis / 1000)"
                let now : Int           = Int(sessionId)!
                self.dbStorage?.saveSessionInfo(SessionInfoModel(sessionId, now, 0))
            } else {
                Logger.instance.debug(message: "Session is live.")
            }
    }
    
    private func getAppLaunchedFields(_ trafficSourceInfo : TrafficSourceInfo?) -> NSDictionary {
        
        let evtData = self.deviceInfo?.getJSONForServer()
        evtData?.setValue(false, forKey: "firstTime")
        
        // Put traffic source info
        if trafficSourceInfo != nil {
            evtData?.setValue(trafficSourceInfo?.getUtmInfo(), forKey: "utmInfo")
            evtData?.setValue(trafficSourceInfo?.getReferrer(), forKey: "referrer")
        }
        
        // Put Location info`
        // if (locationFromUser != null) {
        // evtData.put("Latitude", locationFromUser.getLatitude());
        // evtData.put("Longitude", locationFromUser.getLongitude());
        // }
        
        // send up googleAdID
        //if (this.deviceInfo.getGoogleAdID() != null) {
        //  String baseAdIDKey = "GoogleAdID";
        //String adIDKey = deviceIsMultiUser() ? Constants.MULTI_USER_PREFIX + baseAdIDKey : baseAdIDKey;
        //evtData.put(adIDKey, this.deviceInfo.getGoogleAdID());
        //evtData.put("GoogleAdIDLimit", this.deviceInfo.isLimitAdTrackingEnabled());
        //}
        
        return evtData!
    }
    
    private func isSessionExpired() -> Bool {
        // Check if session is created
        guard let sessionInfo = self.getSessionInfo() else {
            return true
        }
        
        // If session's last background time is zero, session is not expired
        if (sessionInfo.getLastBackgroundTime() == 0) {
            return false
        }
        
        // Check if session is expired
        let now =  Int(Date.currentTimeMillis / 1000)
        let diffInSeconds = now - sessionInfo.getLastBackgroundTime()
        Logger.instance.info(message: "Url -Diff: \(diffInSeconds)")
        if diffInSeconds > Int(Constants.SESSION_LENGTH_MINS * 60) {
            return true
        }
        return false
    }
    
    
    private func getSessionInfo() -> SessionInfoModel? {
        return self.dbStorage?.getSessionInfo()
    }
}
