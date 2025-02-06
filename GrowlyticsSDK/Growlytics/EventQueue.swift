//
//  EventQueue.swift
//  Growlytics
//
//  Created by Pradeep Singh on 15/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation
class EventQueue : NSObject {
    
    private static var instance : EventQueue?
    private var deviceInfo      : DeviceInfo?
    private var config          : Config?
    
    // Sqlite Helper & Syncing
    private var dbStorage       : SqliteHelper?
    
    // Async background processing variables
    let serialQueue = DispatchQueue.init(label: "EventQueue")
    
    var appLaunchPushed         : Bool = false
    
    private override init() {
        self.config     = Config.getInstance()
        self.dbStorage  = SqliteHelper.getInstance()
        self.deviceInfo = DeviceInfo.getInstance()
    }
    
    static func getInstance() -> EventQueue{
        if (instance != nil) {
            Logger.instance.info(suffix: "getInstance", message: "Event Queue Instance is already initialized.")
            return instance!
        }
        
        // Initialize instance.
        instance = EventQueue()
        return instance!
    }
    
    
    func addEventToQueue(_ event : EventModel) {
        self.serialQueue.async {
            // Process Event
            Logger.instance.debug(suffix: "Event Queue", message: "Processing event " + event.toString())
            self.dbStorage?.queueEventToDb(event)
            self.scheduleQueueFlush(after: 0)
        }
    }
    
    func addDeviceRegisterEventToQueue(_ deviceInfo : DeviceInfoModel) {
        self.serialQueue.async {
            // Process Event
            Logger.instance.debug(suffix: "Event Queue", message: "Processing Device Info " + deviceInfo.toString())
            self.dbStorage?.queueDeviceDataToDb(deviceInfo)
            self.scheduleQueueFlushForDeviceRegister(after: 0)
        }
    }
    
    func addNewSessionDataToQueue(_ newSession : NewSessionModel) {
        self.serialQueue.async {
            // Process Event
            Logger.instance.debug(suffix: "Event Queue", message: "Processing New Session Info " + newSession.toString())
            self.dbStorage?.queueNewSessionDataToDb(newSession)
            self.scheduleQueueFlushForNewSession(after: 0)
        }
    }
    
    func addLoginEventToQueue(_ loginInfo : LoginModel) {
        self.serialQueue.async {
            // Process Event
            Logger.instance.debug(suffix: "Event Queue", message: "Processing Login Info " + loginInfo.toString())
            self.dbStorage?.queueLoginDataToDb(loginInfo)
            self.scheduleQueueFlushForLogin(after: 0)
        }
    }
    
    func addLogoutEventToQueue(_ logoutInfo : LogoutModel) {
        self.serialQueue.async {
            // Process Event
            Logger.instance.debug(suffix: "Event Queue", message: "Processing Logout Info " + logoutInfo.toString())
            self.dbStorage?.queueLogoutDataToDb(logoutInfo)
            self.scheduleQueueFlushForLogout(after: 0)
        }
    }
    
    func addCustomerAttributesToQueue(_ customerAttributesInfo : CustomerAttributesModel) {
        self.serialQueue.async {
            // Process Event
            Logger.instance.debug(suffix: "Event Queue", message: "Processing Customer Attributes Info " + customerAttributesInfo.toString())
            self.dbStorage?.queueCustomerAttributesDataToDb(customerAttributesInfo)
            self.scheduleQueueFlushForCustomerAttributes(after: 0)
        }
    }
    
    func saveUpdatedSessionInDb(_ sessionInfoModel: SessionInfoModel) {
        self.dbStorage?.saveSessionInfo(sessionInfoModel)
    }
    
    func getSessionInfo() -> SessionInfoModel? {
        return self.dbStorage?.getSessionInfo()
    }
    
    //MARK: ************** Event Syncing Logic ****************
    
    private func scheduleQueueFlush(after seconds : Int) {
        Logger.instance.debug(suffix: "EventProcessor", message: "Scheduling queue flush.")
        
        let queue = DispatchQueue.init(label: "scheduleQueueFlush")
        queue.asyncAfter(deadline: .now() + .seconds(seconds), execute: {
            self.flushQueueAsync()
        })
        
        Logger.instance.debug(suffix: "EventProcessor", message: "Queue flush scheduled after 0 second.")
    }
    
    private func scheduleQueueFlushForLogin(after seconds : Int) {
        Logger.instance.debug(suffix: "EventProcessor", message: "Scheduling queue flush.")
        
        let queue = DispatchQueue.init(label: "scheduleQueueFlush")
        queue.asyncAfter(deadline: .now() + .seconds(seconds), execute: {
            self.flushQueueLoginAsync()
        })
        
        Logger.instance.debug(suffix: "EventProcessor", message: "Queue flush scheduled after 0 second.")
    }
    
    @objc private func flushQueueAsync() {
        self.serialQueue.async {
            self.synchronized(self) {
                Logger.instance.debug(suffix: "EventProcessor-DbFlush", message: "Executing db flush.")
                
                if (!CommonUtil.isNetworkOnline()) {
                    Logger.instance.debug(suffix: "EventProcessor-DbFlush", message: "Network connectivity unavailable. Will retry after 2 minutes.")
                    self.scheduleQueueFlush(after: 60 * 2)
                    return
                }
                
                // Send all the events one by one on http, at the same time
                if let arrEvt = self.dbStorage?.getAnyQueuedEvent(), arrEvt.count>0{
                    debugPrint("Event Count: ", arrEvt.count)
                    for evt in arrEvt{
                        Logger.instance.info(suffix: "Event Processor", message: "Event id is " + (evt.id ?? ""))
                        evt.timestamp = Int(Date.currentTimeMillis) //api call timestamp
                        //HTTP Request
                        HttpManager.getInstance().sendOverHttp(eventData: evt, endPoints: "/events/mobile-sdk-event") { (json, isTimeOutError) in
                            if !isTimeOutError{
                                if json != nil{
                                    // Remove event from db
                                    let versionOfLastRun = UserDefaults.standard.object(forKey: Constants.lastAppVersion) as? String
                                    if versionOfLastRun == nil {
                                        let currentVersion =  Bundle.main.versionNumber
                                        UserDefaults.standard.set(currentVersion, forKey: Constants.lastAppVersion)
                                    }
                                    
                                    self.dbStorage?.removeEventFromDb(evt.id!)
                                }
                            }else{
                                Logger.instance.debug(suffix: "EventProcessor", message: "An exception occurred while clearing queue, will retry: ")
                                self.scheduleQueueFlush(after: 15) // 15 Sec
                            }
                        }
                    }
                }
                Logger.instance.info(message: "Queue flushed.")
            }
        }
    }
    
    func removeExpiredEventsFromDb(){
        self.dbStorage?.removeExpiredEventsFromDb()
    }
    
    //private func isReadyToProcessEventData(_ event : EventModel)->Bool {
        // Check if session is created.
        //return event.eventType == .appLaunch || self.appLaunchPushed
    //}
    
    @objc private func flushQueueLoginAsync() {
        //self.serialQueue.async {
            //self.synchronized(self) {
                Logger.instance.debug(suffix: "EventProcessor-DbFlush", message: "Executing db flush.")
                
                if (!CommonUtil.isNetworkOnline()) {
                    Logger.instance.debug(suffix: "EventProcessor-DbFlush", message: "Network connectivity unavailable. Will retry after 2 minutes.")
                    self.scheduleQueueFlushForLogin(after: 60 * 2)
                    return
                }
                // Send all the new session data one by one on http, at the same time
                if let arrLoginData = self.dbStorage?.getAnyQueuedLoginData(), arrLoginData.count>0{
                    debugPrint("Login Data Count: ", arrLoginData.count)
                    for loginInfo in arrLoginData{
                        Logger.instance.info(suffix: "Event Processor", message: "Login id is " + loginInfo.id!)
                        loginInfo.timestamp = Int(Date.currentTimeMillis) //api call timestamp
                        //HTTP Request
                        HttpManager.getInstance().sendOverHttp(newLoginData: loginInfo, endPoints: "/events/mobile-sdk-login") { (json, isTimeOutError) in
                            if !isTimeOutError{
                                if json != nil{
                                    // Remove event from db
                                    self.dbStorage?.removeLoginDataFromDb(loginInfo.id!)
                                }
                            }else{
                                Logger.instance.debug(suffix: "EventProcessor", message: "An exception occurred while clearing queue, will retry: ")
                                self.scheduleQueueFlushForLogin(after: 15) // 15 Sec
                            }
                        }
                    }
                }
                
                Logger.instance.info(message: "Queue flushed.")
        //    }
        //}
    }
    
    private func scheduleQueueFlushForLogout(after seconds : Int) {
        Logger.instance.debug(suffix: "EventProcessor", message: "Scheduling queue flush.")
        
        let queue = DispatchQueue.init(label: "scheduleQueueFlush")
        queue.asyncAfter(deadline: .now() + .seconds(seconds), execute: {
            self.flushQueueLogoutAsync()
        })
        
        Logger.instance.debug(suffix: "EventProcessor", message: "Queue flush scheduled after 0 second.")
    }
    
    @objc private func flushQueueLogoutAsync() {
        Logger.instance.debug(suffix: "EventProcessor-DbFlush", message: "Executing db flush.")
        
        if (!CommonUtil.isNetworkOnline()) {
            Logger.instance.debug(suffix: "EventProcessor-DbFlush", message: "Network connectivity unavailable. Will retry after 2 minutes.")
            self.scheduleQueueFlushForLogout(after: 60 * 2)
            return
        }
        // Send all the new session data one by one on http, at the same time
        if let arrLogoutData = self.dbStorage?.getAnyQueuedLogoutData(), arrLogoutData.count>0{
            debugPrint("Logout Data Count: ", arrLogoutData.count)
            for logoutInfo in arrLogoutData{
                Logger.instance.info(suffix: "Event Processor", message: "Logout id is " + logoutInfo.id!)
                logoutInfo.timestamp = Int(Date.currentTimeMillis) //api call timestamp
                //HTTP Request
                HttpManager.getInstance().sendOverHttp(logoutData: logoutInfo, endPoints: "/events/mobile-sdk-logout") { (json, isTimeOutError) in
                    if !isTimeOutError{
                        if json != nil{
                            UserDefaults.standard.removeObject(forKey: "DeviceUdid")
                            UserDefaults.standard.removeObject(forKey: "CustomerID")
                            globalUDID = ""
                            //Remove event from db
                            self.dbStorage?.removeLogoutDataFromDb(logoutInfo.id!)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                                EventProcessor.getInstance().trackDeviceRegister()
                            })
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                                EventProcessor.getInstance().trackNewSession(isFirstSession: false)
                            })
                            
                        }
                    }else{
                        Logger.instance.debug(suffix: "EventProcessor", message: "An exception occurred while clearing queue, will retry: ")
                        self.scheduleQueueFlushForLogout(after: 15) // 15 Sec
                    }
                }
            }
        }
        
        Logger.instance.info(message: "Queue flushed.")
    }
    
    private func scheduleQueueFlushForCustomerAttributes(after seconds : Int) {
        Logger.instance.debug(suffix: "EventProcessor", message: "Scheduling queue flush.")
        
        let queue = DispatchQueue.init(label: "scheduleQueueFlush")
        queue.asyncAfter(deadline: .now() + .seconds(seconds), execute: {
            self.flushQueueCustomerAttributesAsync()
        })
        
        Logger.instance.debug(suffix: "EventProcessor", message: "Queue flush scheduled after 0 second.")
    }
    
    @objc private func flushQueueCustomerAttributesAsync() {
        Logger.instance.debug(suffix: "EventProcessor-DbFlush", message: "Executing db flush.")
        
        if (!CommonUtil.isNetworkOnline()) {
            Logger.instance.debug(suffix: "EventProcessor-DbFlush", message: "Network connectivity unavailable. Will retry after 2 minutes.")
            self.scheduleQueueFlushForCustomerAttributes(after: 60 * 2)
            return
        }
        // Send all the new session data one by one on http, at the same time
        if let arrCustomerAttributeData = self.dbStorage?.getAnyQueuedCustomerAttributeData(), arrCustomerAttributeData.count>0{
            debugPrint("Customer Attribute Data Count: ", arrCustomerAttributeData.count)
            for customerAttribute in arrCustomerAttributeData{
                Logger.instance.info(suffix: "Event Processor", message: "Customer Attribute id is " + customerAttribute.id!)
                customerAttribute.timestamp = Int(Date.currentTimeMillis) //api call timestamp
                //HTTP Request
                HttpManager.getInstance().sendOverHttp(customerData: customerAttribute, endPoints: "/events/mobile-sdk-update") { (json, isTimeOutError) in
                    if !isTimeOutError{
                        if json != nil{
                            // Remove event from db
                            self.dbStorage?.removeCustomerAttributesDataFromDb(customerAttribute.id!)
                        }
                    }else{
                        Logger.instance.debug(suffix: "EventProcessor", message: "An exception occurred while clearing queue, will retry: ")
                        self.scheduleQueueFlushForCustomerAttributes(after: 15) // 15 Sec
                    }
                }
            }
        }
        
        Logger.instance.info(message: "Queue flushed.")
    }
    
    private func scheduleQueueFlushForDeviceRegister(after seconds : Int) {
        Logger.instance.debug(suffix: "EventProcessor", message: "Scheduling queue flush.")
        
        let queue = DispatchQueue.init(label: "scheduleQueueFlush")
        queue.asyncAfter(deadline: .now() + .seconds(seconds), execute: {
            self.flushQueueDeviceAsync()
        })
        
        Logger.instance.debug(suffix: "EventProcessor", message: "Queue flush scheduled after 0 second.")
    }
    
    @objc private func flushQueueDeviceAsync() {
        Logger.instance.debug(suffix: "EventProcessor-DbFlush", message: "Executing db flush.")
        
        if (!CommonUtil.isNetworkOnline()) {
            Logger.instance.debug(suffix: "EventProcessor-DbFlush", message: "Network connectivity unavailable. Will retry after 2 minutes.")
            self.scheduleQueueFlushForDeviceRegister(after: 60 * 2)
            return
        }
        // Send all the new session data one by one on http, at the same time
        if let arrDeviceData = self.dbStorage?.getAnyQueuedDeviceData(), arrDeviceData.count>0 && UserDefaults.standard.object(forKey: "DeviceUdid") as? String == nil{
            debugPrint("Device data Count: ", arrDeviceData.count)
            guard let device = arrDeviceData.first else { return }
            Logger.instance.info(suffix: "Event Processor", message: "Device id is " + (device.id ?? ""))
            device.timestamp = Int(Date.currentTimeMillis) //api call timestamp
                //HTTP Request
            HttpManager.getInstance().sendOverHttp(deviceData: device, endPoints: "/events/mobile-sdk-device") { (json, isTimeOutError) in
                    if !isTimeOutError{
                        if json != nil{
                            // Remove device data from db
                            UserDefaults.standard.set(device.id, forKey: "DeviceUdid")
                            UserDefaults.standard.synchronize()
                            self.dbStorage?.removeDeviceDataFromDb(device.id!)
                        }
                    }else{
                        Logger.instance.debug(suffix: "EventProcessor", message: "An exception occurred while clearing queue, will retry: ")
                        self.scheduleQueueFlushForDeviceRegister(after: 15) // 15 Sec
                    }
                }
        }
        
        Logger.instance.info(message: "Queue flushed.")
    }
    
    private func scheduleQueueFlushForNewSession(after seconds : Int) {
        Logger.instance.debug(suffix: "EventProcessor", message: "Scheduling queue flush.")
        
        let queue = DispatchQueue.init(label: "scheduleQueueFlush")
        queue.asyncAfter(deadline: .now() + .seconds(seconds), execute: {
            self.flushQueueNewSession()
        })
        
        Logger.instance.debug(suffix: "EventProcessor", message: "Queue flush scheduled after 0 second.")
    }
    
    @objc private func flushQueueNewSession() {
        Logger.instance.debug(suffix: "EventProcessor-DbFlush", message: "Executing db flush.")
        
        if (!CommonUtil.isNetworkOnline()) {
            Logger.instance.debug(suffix: "EventProcessor-DbFlush", message: "Network connectivity unavailable. Will retry after 2 minutes.")
            self.scheduleQueueFlushForNewSession(after: 60 * 2)
            return
        }
        // Send all the new session data one by one on http, at the same time
        if let arrNewSession = self.dbStorage?.getAnyQueuedNewSession(), arrNewSession.count>0{
            debugPrint("New Session Count: ", arrNewSession.count)
            for newSession in arrNewSession{
                Logger.instance.info(suffix: "Event Processor", message: "New Session id is " + newSession.id!)
                newSession.timestamp = Int(Date.currentTimeMillis) //api call timestamp
                //HTTP Request
                HttpManager.getInstance().sendOverHttp(newSessionData: newSession, endPoints: "/events/mobile-sdk-session") { (json, isTimeOutError) in
                    if !isTimeOutError{
                        if json != nil{
                            // Remove event from db
                            let currentTimestamp = Int(Date.currentTimeMillis)
                            UserDefaults.standard.set(currentTimestamp, forKey: "PauseTime")
                            self.dbStorage?.removeNewSessionFromDb(newSession.id!)
                        }
                    }else{
                        Logger.instance.debug(suffix: "EventProcessor", message: "An exception occurred while clearing queue, will retry: ")
                        self.scheduleQueueFlushForNewSession(after: 15) // 15 Sec
                    }
                }
            }
        }
        
        Logger.instance.info(message: "Queue flushed.")
    }
    
}
