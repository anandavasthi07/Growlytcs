//
//  EventProcessor.swift
//  Growlytics
//
//  Created by Pradeep Singh on 06/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation

class EventProcessor: NSObject {
    
    // Singleton instance
    private static var instance     : EventProcessor?
    private var config              : Config?
    private var deviceInfo          : DeviceInfo?
    private var eventQueue          : EventQueue?
    private var appLaunchedHandler  : AppLaunchedHandler?
    private var appInstalledHandler : AppInstalledHandler?
    
    // Sqlite Helper & Syncing
    private var dbStorage           : JSONHelper
    
    // Async background processing variables
    let serialQueue = DispatchQueue.init(label: "EventProcessor")
    
    // App launch event variables
    private var trafficSourceInfo       : TrafficSourceInfo?
    
    
    //MARK:************ Start : Singleton Class Methods **************
    
    private override init( ) {
        self.config                 = Config.getInstance()
        self.deviceInfo             = DeviceInfo.getInstance()
        self.dbStorage              = JSONHelper.getInstance()
        self.eventQueue             = EventQueue.getInstance()
        self.appLaunchedHandler     = AppLaunchedHandler.getInstance()
        self.appInstalledHandler    = AppInstalledHandler.getInstance()
    }
    
    static func getInstance() -> EventProcessor {
        if (instance != nil) {
            Logger.instance.info(suffix: "EventProcessor", message: "Instance is already initialized.")
            return instance!
        }
        
        // Initialize instance.
        instance =  EventProcessor()
        return instance!
    }
    
    //MARK:************ End : Singleton Class Methods **************
    
    //MARK:************ Start : Activity Callback Methods **********
    
    func onActivityCreated() {
        self.serialQueue.async {
            // Read deep link if app launch
            Logger.instance.debug(suffix : "EventProcessor", message: "Activity Created.");
            self.processDeepLink(URL(string: "")!)
        }
    }
    
    func onActivityResumed(isFirstTime: Bool) {
        self.serialQueue.async {
            Logger.instance.info(suffix: "Activity", message: "App in foreground")
            
            // Handle app launched logic
            self.appLaunchedHandler?.handleAppLaunched(self.trafficSourceInfo, isFirstTime: isFirstTime)
        }
    }
    
    func onActivityPaused() {
        self.serialQueue.async {
            
            Logger.instance.info(suffix : "Activity Pause", message: "App going in background");
            
            // Set last background time
            let sessionInfo : SessionInfoModel? = self.eventQueue?.getSessionInfo()!
            if (sessionInfo != nil) {
                let now = (Date.currentTimeMillis / 1000)
                sessionInfo?.setLastBackgroundTime(Int(now))
                self.eventQueue?.saveUpdatedSessionInDb(sessionInfo!)
                Logger.instance.info(suffix: "Activity Pause", message: "Session info updated with last time \(now)")
            } else {
                Logger.instance.info(suffix: "On Resume", message: "Session info not found. Update session skipped.")
            }
        }
    }
    
    func trackAppInstalledEvent() {
        self.appInstalledHandler?.trackAppInstalledEvent()
    }
    
    func identifyUser(_ uniqueCustomerId : String? , _ profileAttributes : [String : Any]?) {

    }
    
    func trackCustomEvent(_ eventName : String, _ eventAttributes: [String : Any]?) {
        self.serialQueue.async {
            
            // Validate event name
            var result = ValidationUtil.validateEventName(eventName)
            if (result != nil) {
                Logger.instance.error(suffix: "Growlytics", message: "Invalid Event Name. Event reporting aborted. Reason: \(result!)")
                return
            }
            
            // Build event object
            let event = EventModel()
            event.id = CommonUtil.generateUUID()
            if let customerId = UserDefaults.standard.value(forKey: "CustomerID") as? String {
                event.sid = customerId
            }
            event.session = self.deviceInfo?.getSessionSchema(isFirstSession: false)
            event.device = self.deviceInfo?.getJSONForServer()
            event.meta = self.deviceInfo?.getMetaDataSchema()
            event.timestamp = 0
            event.eventTimestamp = Int(Date.currentTimeMillis)
            
            // Process attributes if provided.
            if (eventAttributes != nil) {
                
                // Validate Attributes
                result = ValidationUtil.validateEventAttributes(eventAttributes!)
                if (result != nil) {
                    Logger.instance.error(suffix: "Growlytics", message: "Analytics.pushEvent() called with invalid attributes. Event will be ignored. Reason: \(result!)")
                    return
                }
                event.event = self.customEventSchema(eventName, eventAttributes)
            }
            
            // Add event to queue.
            self.eventQueue?.addEventToQueue(event)
            Logger.instance.info(suffix: "Custom Event", message: "Added custom event to event queue.")
        }
    }
    
    private func processDeepLink(_ deepLink : URL ) {
        let utmInfo = UriUtil.parseUtmInfo(deepLink)
        let referrer = deepLink.absoluteString
        
        // Put processed json to local variable to be sent with app launch
        self.trafficSourceInfo = TrafficSourceInfo(referrer, utmInfo)
    }
    
    //MARK:*************** End : Activity Callback Methods ****************
    
    //MARK: ***************** START:  Process App Launched Event *************
    
    private func checkTimeoutSession() {
        //        if (appLastSeen <= 0) return;
        //        long now = System.currentTimeMillis();
        //        if ((now - appLastSeen) > Constants.SESSION_LENGTH_MINS * 60 * 1000) {
        //            getConfigLogger().verbose(getAccountId(), "SessionInfo Timed Out");
        //            destroySession();
        //            setCurrentActivity(null);
        //        }
    }
    
    
    //MARK: ********************* START: Process Notification Events **********************

    func trackNotificationViewed(_ trackingId : String? ) {
//        if trackingId == nil || trackingId?.isEmpty ?? true {
//            Logger.instance.info(suffix: "Notification", message: "Notification Tracking Id is missing. Notification viewed event will not be tracked.")
//            return
//        }
//
//        self.serialQueue.async {
//
//            let event = EventModel()
//            event.name = "Notification Viewed"
//            event.eventType = .notificationImpression
//            event.waitForSession = false
//            event.eventTime = Int(Date.currentTimeMillis / 1000)
//
//            let info = NSMutableDictionary()
//            info["id"] = trackingId
//            event.info = info
//
//            // Add event to queue.
//            self.eventQueue?.addEventToQueue(event)
//            Logger.instance.info(suffix: "Notification", message: "Added notification viewed  event to event queue.")
//        }
    }

    func trackNotificationClicked(trackingId : String? , actionId : String? ) {
        
//        if trackingId == nil || trackingId?.isEmpty ?? true {
//            Logger.instance.info(suffix: "Notification", message: "Notification Tracking Id is missing. Notification clicked event will not be tracked.")
//            return;
//        }
//
//        self.serialQueue.async {
//
//            let event = EventModel()
//            event.name = "Notification Viewed"
//            event.eventType = .notificationClicked
//            event.waitForSession = false
//            event.eventTime = Int(Date.currentTimeMillis / 1000)
//
//            let info = NSMutableDictionary()
//            info["id"] = trackingId
//
//            if (actionId != nil) {
//                info["actionId"] = actionId
//            }
//
//            event.info = info
//
//            // Add event to queue.
//            self.eventQueue?.addEventToQueue(event)
//
//            Logger.instance.info(suffix: "Notification", message: "Added notification click event to event queue.")
//        }
    }
    
      //MARK: ********************* END: Process Notification Events **********************
    
    //MARK: ********************* START: Process Device Register **********************
    func trackDeviceRegister() {
        self.serialQueue.async {

            let deviceInfo = DeviceInfoModel()
            deviceInfo.id = CommonUtil.generateUUID()
            deviceInfo.device = self.deviceInfo?.getJSONForServer()
            deviceInfo.meta = self.deviceInfo?.getMetaDataSchema()
            deviceInfo.timestamp = 0
            deviceInfo.eventTimestamp = Int(Date.currentTimeMillis)
            
            // Add event to queue.
            self.eventQueue?.addDeviceRegisterEventToQueue(deviceInfo)
            Logger.instance.info(suffix: "Notification", message: "Added notification viewed  event to event queue.")
        }
    }
    //MARK: ********************* END: Process Device Register **********************
    
    //MARK: ********************* START: Process New Session **********************
    func trackNewSession(isFirstSession: Bool) {
        self.serialQueue.async {

            let newSession = NewSessionModel()
            newSession.id = CommonUtil.generateUUID()
            if let customerId = UserDefaults.standard.value(forKey: "CustomerID") as? String {
                newSession.sid = customerId
            }
            newSession.session = self.deviceInfo?.getSessionSchema(isFirstSession: isFirstSession)
            newSession.data = self.deviceInfo?.getNewSessionDataSchema()
            newSession.device = self.deviceInfo?.getJSONForServer()
            newSession.meta = self.deviceInfo?.getMetaDataSchema()
            newSession.timestamp = 0
            newSession.eventTimestamp = Int(Date.currentTimeMillis)
            
            // Add event to queue.
            self.eventQueue?.addNewSessionDataToQueue(newSession)
            Logger.instance.info(suffix: "Notification", message: "Added notification viewed  event to event queue.")
        }
    }
    
    //MARK: ********************* START: Process Login Event **********************
    func trackLoginEvent(_ uniqueCustomerId : String? , _ profileAttributes : [String : Any]?) {
        self.serialQueue.async {
            
            // Check if plugin is disabled.
            if (Config.getInstance().isDisable()) {
                Logger.instance.info(message: "Growlytics is disabled from config.")
                return
            }
            
            // Build event object
            let loginInfo = LoginModel()
            loginInfo.id = CommonUtil.generateUUID()
            loginInfo.session = self.deviceInfo?.getSessionSchema(isFirstSession: false)
            loginInfo.device = self.deviceInfo?.getJSONForServer()
            loginInfo.meta = self.deviceInfo?.getMetaDataSchema()
            loginInfo.timestamp = 0
            loginInfo.eventTimestamp = Int(Date.currentTimeMillis)
            
            // Process attributes if provided.
            if (profileAttributes != nil) {
                
                // Validate Attributes
                let result = ValidationUtil.validateEventAttributes(profileAttributes!)
                if (result != nil) {
                    Logger.instance.error(suffix: "Growlytics", message: "Analytics.pushProfile() called with invalid customer attributes. Event will be ignored. Reason: \(result!)")
                    return
                }
                loginInfo.user = self.loginUserSchema(uniqueCustomerId, profileAttributes)
                
                // Add login event to queue.
                self.eventQueue?.addLoginEventToQueue(loginInfo)
                Logger.instance.info(suffix: "Notification", message: "Added login event to event queue.")
            }
        }
    }
    
    func loginUserSchema(_ userCustomerId: String?, _ profileAttributes : [String : Any]?) -> NSMutableDictionary {
        let userDict = NSMutableDictionary()
        userDict.setValue(userCustomerId, forKey: "id")
        var userAttributes = [NSMutableDictionary]()
        for (key, value) in profileAttributes! {
            var attributeInfo = NSMutableDictionary()
            attributeInfo["name"] = key
            attributeInfo["value"] = value
            let type = String(describing: type(of: value)).lowercased()
            if type == "int" {
                attributeInfo["type"] = "integer"
            } else if type == "float" {
                attributeInfo["type"] = "float"
            } else if type == "bool" {
                attributeInfo["type"] = "boolean"
            } else if type == "double" {
                attributeInfo["type"] = "double"
            } else if type == "date" {
                attributeInfo["type"] = "date"
            } else if type == "string" {
                attributeInfo["type"] = "string"
            }
            userAttributes.append(attributeInfo)
        }
        userDict.setValue(userAttributes, forKey: "attributes")
        print("User Dict: \(userDict)")
        return userDict
    }
    
    func customEventSchema(_ eventName: String?, _ eventAttributes : [String : Any]?) -> NSMutableDictionary {
        let eventDict = NSMutableDictionary()
        eventDict.setValue(eventName, forKey: "name")
        var properties = [NSMutableDictionary]()
        for (key, value) in eventAttributes! {
            let attributeInfo = NSMutableDictionary()
            attributeInfo["name"] = key
            attributeInfo["value"] = value
            let type = String(describing: type(of: value)).lowercased()
            if type == "int" {
                attributeInfo["type"] = "integer"
            } else if type == "float" {
                attributeInfo["type"] = "float"
            } else if type == "bool" {
                attributeInfo["type"] = "boolean"
            } else if type == "double" {
                attributeInfo["type"] = "double"
            } else if type == "date" {
                attributeInfo["type"] = "date"
            } else if type == "string" {
                attributeInfo["type"] = "string"
            }
            properties.append(attributeInfo)
        }
        eventDict.setValue(properties, forKey: "properties")
        eventDict.setValue(eventAttributes, forKey: "rawProperties")
        print("Event properties Dict: \(eventDict)")
        return eventDict
    }
    
    //MARK: ********************* START: Process Logout Event **********************
    func trackLogoutEvent() {
        self.serialQueue.async {
            
            // Check if plugin is disabled.
            if (Config.getInstance().isDisable()) {
                Logger.instance.info(message: "Growlytics is disabled from config.")
                return
            }
            
            // Build event object
            let logoutInfo = LogoutModel()
            logoutInfo.id = CommonUtil.generateUUID()
            if let customerId = UserDefaults.standard.value(forKey: "CustomerID") as? String {
                logoutInfo.sid = customerId
            }
            logoutInfo.session = self.deviceInfo?.getSessionSchema(isFirstSession: false)
            logoutInfo.device = self.deviceInfo?.getJSONForServer()
            logoutInfo.meta = self.deviceInfo?.getMetaDataSchema()
            logoutInfo.timestamp = 0
            logoutInfo.eventTimestamp = Int(Date.currentTimeMillis)
            
            // Add logout event to queue.
            self.eventQueue?.addLogoutEventToQueue(logoutInfo)
            Logger.instance.info(suffix: "Notification", message: "Added logout event to event queue.")
        }
    }
    
    //MARK: ********************* START: Process Update Customer Attributes Event **********************
    func trackUpdateCustomer(_ customerAttributes: [String : Any]?) {
        self.serialQueue.async {
            
            // Check if plugin is disabled.
            if (Config.getInstance().isDisable()) {
                Logger.instance.info(message: "Growlytics is disabled from config.")
                return
            }
            
            // Build event object
            let updateCustomer = CustomerAttributesModel()
            updateCustomer.id = CommonUtil.generateUUID()
            if let customerId = UserDefaults.standard.value(forKey: "CustomerID") as? String {
                updateCustomer.sid = customerId
            }
            updateCustomer.session = self.deviceInfo?.getSessionSchema(isFirstSession: false)
            updateCustomer.device = self.deviceInfo?.getJSONForServer()
            updateCustomer.meta = self.deviceInfo?.getMetaDataSchema()
            updateCustomer.timestamp = 0
            updateCustomer.eventTimestamp = Int(Date.currentTimeMillis)
            
            // Process attributes if provided.
            if (customerAttributes != nil) {
                
                // Validate Attributes
                let result = ValidationUtil.validateEventAttributes(customerAttributes!)
                if (result != nil) {
                    Logger.instance.error(suffix: "Growlytics", message: "Analytics.pushProfile() called with invalid customer attributes. Customer attributes will be ignored. Reason: \(result!)")
                    return
                }
                updateCustomer.data = self.customerAttributesData(customerAttributes)
                
                // Add login event to queue.
                self.eventQueue?.addCustomerAttributesToQueue(updateCustomer)
                Logger.instance.info(suffix: "Notification", message: "Added update customer attibutes to event queue.")
            }
        }
    }
    
    func customerAttributesData(_ customerAttributes : [String : Any]?) -> [NSMutableDictionary] {
        var customerAttributesData = [NSMutableDictionary]()
        for (key, value) in customerAttributes! {
            var attributeInfo = NSMutableDictionary()
            attributeInfo["name"] = key
            attributeInfo["value"] = value
            let type = String(describing: type(of: value)).lowercased()
            if type == "int" {
                attributeInfo["type"] = "integer"
            } else if type == "float" {
                attributeInfo["type"] = "float"
            } else if type == "bool" {
                attributeInfo["type"] = "boolean"
            } else if type == "double" {
                attributeInfo["type"] = "double"
            } else if type == "date" {
                attributeInfo["type"] = "date"
            } else if type == "string" {
                attributeInfo["type"] = "string"
            }
            customerAttributesData.append(attributeInfo)
        }
        return customerAttributesData
    }
    
}

