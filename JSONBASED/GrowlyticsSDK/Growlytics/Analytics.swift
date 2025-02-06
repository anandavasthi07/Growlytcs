//
//  Analytics.swift
//  Growlytics
//
//  Created by Pradeep Singh on 06/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit

public class Analytics {
    
    // Singleton instance
    private static var instance         : Analytics?
    private var config                  : Config!
    private var eventProcessor          : EventProcessor?
    
    //MARK: ********************* Singleton Instance **********************************
    
   private init( ) {
        self.config = Config.getInstance()
        self.eventProcessor = EventProcessor.getInstance()
    }
    
    public static func getInstance() -> Analytics {
        
        if (instance != nil) {
            Logger.instance.info(suffix: "Analytics", message: "Analytics Instance is already initialized.")
            return instance!
        }
        
        // Initialize instance.
        instance = Analytics()
        return instance!
    }
    
    //MARK: ********************* End: Singleton Instance *****************************
    
    //MARK: ********************* Start: API Methods **********************************
    
    public func track(eventName : String) {
        if (self.config.isDisable()) {
            Logger.instance.info(message: "Growlytics is disabled from config.")
            return
        }
        self.track(eventName, nil)
    }
    
    public func trackAppInstalled() {
        if (Config.getInstance().isDisable()) {
            Logger.instance.info(message : "Growlytics is disabled from config.")
            return
        }
        self.eventProcessor!.trackAppInstalledEvent()
    }
    
    
    /**
     * Track an event with attributes(in key value pair).
     * <p>
     * DataType validation for event Attributes:
     * Attribute Key: Key must be string not more than 100 characters.
     * Attribute Values: The value of attribute can be of type String, Integer, Long, Double, Float, Boolean, Character and Date(java.util.date) only.
     * On Attribute validation failure, error message will be printed as warning and event will be ignored and will not be sent to Growlytics server.
     *
     * @param eventName       The name of the event
     * @param eventAttributes : A NSDictionary with keys as strings, and values as any,
     *
     */
    
    //MARK:- Track Event
    public func track(_ eventName : String, _ eventAttributes : [String : Any]?) {
        
        if (self.config.isDisable()) {
            Logger.instance.info(message: "Growlytics is disabled from config.")
            return
        }
        self.eventProcessor?.trackCustomEvent(eventName, eventAttributes)
    }
    
    public func identify(_ profileAttributes : [String : Any]?) {
        
        if (self.config.isDisable()) {
            Logger.instance.info(message : "Growlytics is disabled from config.")
            return
        }
        self.eventProcessor?.identifyUser(nil, profileAttributes)
    }
    
    public func identify(_ uniqueCustomerId : String?, _ profileAttributes : [String : Any]?) {
        
        if (self.config.isDisable()) {
            Logger.instance.info(message : "Growlytics is disabled from config.")
            return;
        }
        
        self.eventProcessor?.identifyUser(uniqueCustomerId, profileAttributes)
    }
    
    //MARK:- Login Event Track
    public func loginUser(_ uniqueCustomerId : String?, _ profileAttributes : [String : Any]?) {
        
        UserDefaults.standard.set(uniqueCustomerId, forKey: "CustomerID")
        
        if (self.config.isDisable()) {
            Logger.instance.info(message : "Growlytics is disabled from config.")
            return;
        }
        
        self.eventProcessor?.trackLoginEvent(uniqueCustomerId, profileAttributes)
    }
    
    //MARK:- Logout Event Track
    public func logoutUser() {
                
        if (self.config.isDisable()) {
            Logger.instance.info(message : "Growlytics is disabled from config.")
            return;
        }
        
        self.eventProcessor?.trackLogoutEvent()
    }
    
    //MARK:- Update Customer Attribute Track
    public func updateCustomer(_ customerAttributes : [String : Any]?) {
                
        if (self.config.isDisable()) {
            Logger.instance.info(message : "Growlytics is disabled from config.")
            return;
        }
        
        self.eventProcessor?.trackUpdateCustomer(customerAttributes)
    }
    
    private func resetIdentity() {
        if (self.config.isDisable()) {
            Logger.instance.info(message : "Growlytics is disabled from config.")
            return
        }
    }
    
    //MARK: ********************* End: API Methods ************************************
    
    
    //MARK: ********************* Start: Activity Methods *****************************
    
    func onActivityCreated() {
        
        if (self.config.isDisable()) {
            Logger.instance.info(message: "Growlytics is disabled from config.")
            return
        }
        
        if (Analytics.instance == nil) {
            Logger.instance.info(message: "Instance is null in onActivityResumed!")
            return
        }
        
        self.eventProcessor?.onActivityCreated()
    }
    
    func onActivityResumed() {
        
        //Check timing for app in background
        if let pauseTime = UserDefaults.standard.value(forKey: "PauseTime") as? Int {
            let timeDifference = CommonUtil.differenceBetweenTime(startTimestamp: pauseTime, endTimestamp: Int(Date.currentTimeMillis))
            print("Time Difference between pause and resume: \(timeDifference) mins")
            if timeDifference > 30 {
                EventProcessor.getInstance().trackNewSession(isFirstSession: false)
                self.eventProcessor!.onActivityResumed(isFirstTime: false)
            } else {
                return
            }
        } else {
            EventProcessor.getInstance().trackNewSession(isFirstSession: true)
            self.eventProcessor!.onActivityResumed(isFirstTime: true)
        }
        
        if (self.config.isDisable()) {
            Logger.instance.info(message: "Growlytics is disabled from config.")
            return
        }
        
        if (Analytics.instance == nil) {
            Logger.instance.info(message: "Instance is null in onActivityResumed!")
            return
        }
    }
    
    func onActivityPaused() {
        
        //Save the timestamp when app goes in background
        let currentTimestamp = Int(Date.currentTimeMillis)
        UserDefaults.standard.set(currentTimestamp, forKey: "PauseTime")
        
        if (self.config.isDisable()) {
            Logger.instance.info(message : "Growlytics is disabled from config.")
            return
        }
        
        if (Analytics.instance == nil) {
            Logger.instance.info(message : "Instance is null in onActivityPaused!")
            return
        }
        
        //self.eventProcessor?.onActivityPaused()
    }
    
    //MARK: ********************* Start: Activity Methods ***************************
}
