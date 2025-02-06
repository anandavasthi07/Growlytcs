//
//  DeviceInfo.swift
//  Growlytics
//
//  Created by Pradeep Singh on 05/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit
import CoreTelephony

class DeviceInfo {
    
    private static var instance : DeviceInfo?
    private var cachedInfo : DeviceCachedInfo?
    
    
    //MARK: ********************* START : Singleton Instance **********************
    
    private init() {
        self.cachedInfo = DeviceCachedInfo()
    }
    
    static func getInstance() -> DeviceInfo{
        if (self.instance == nil) {
            self.instance = DeviceInfo()
        }
        return self.instance!
    }
    
    //MARK: ********************* END : Singleton Instance **********************
    
    //MARK: ********************* START: All Functions **********************
    public func getLanguage() -> String  {
        return self.cachedInfo!.language!
    }
    
    public func getDeviceId() -> String {
        return self.cachedInfo!.deviceId!
    }
    
    public func getDeviceType() -> String{
        return self.cachedInfo!.deviceType!
    }
    
    public func getAppVersionName() -> String{
        return self.cachedInfo!.appVersionName!
    }
    
    public func getAppVersionCode() -> Int {
        return self.cachedInfo!.appVersionCode!
    }
    
    public func getOsName() -> String{
        return self.cachedInfo!.osName!
    }
    
    public func getOsVersion() -> String{
        return self.cachedInfo!.osVersion!
    }
    
    public func getManufacturer() -> String{
        return self.cachedInfo!.manufacturer!
    }
    
    public func getModel() -> String{
        return self.cachedInfo!.model!
    }
    
    public func getCarrier() -> String{
        return self.cachedInfo!.carrier!
    }
    
    public func getCountryCode() -> String{
        return self.cachedInfo!.countryCode!
    }
    
    public func getSdkVersion() -> String{
        return self.cachedInfo!.sdkVersion!
    }
    
//    public func getFCMSenderID() -> String {
//        return  Config.getInstance().getFcmSenderId()
//    }
    
    public func getNotificationsEnabledForUser() -> Bool{
        return self.cachedInfo!.notificationsEnabled!
    }
    
    //
    //    static func getAppIconAsIntId(final Context context) -> Int {
    //            ApplicationInfo ai = context.getApplicationInfo();
    //            return ai.icon;
    //    }
    
    public func getMetaDataSchema() -> NSMutableDictionary {
         
         let metaData = NSMutableDictionary()
         
         metaData.setValue(Int((Date.currentTimeMillis)), forKey: "deviceTs")
         metaData.setValue(self.getTimestampFromUTC(), forKey: "deviceTz")
         metaData.setValue(self.getDeviceTzOffset(), forKey: "deviceTzOffset")
         
         return metaData
     }
    
    public func getTimestampFromUTC() -> String {
        let millisecondsFromGMT = self.getDeviceTzOffset()
        let currentTimestamp = Int((Date.currentTimeMillis))
        print("millisecondsFromGMT: \(millisecondsFromGMT)\ncurrentTimestamp: \(currentTimestamp)")
        return "-\(millisecondsFromGMT)"
    }
    
    public func getDeviceTzOffset() -> Int {
        let timeZone = TimeZone.current
        let secondsFromGMT = timeZone.secondsFromGMT()
        let millisecondsFromGMT = secondsFromGMT * 1000
        return millisecondsFromGMT
    }
    
    public func getNewSessionDataSchema() -> NSMutableDictionary {
         let data = NSMutableDictionary()
         data.setValue("Screen Name", forKey: "screenName")
         data.setValue(NSNull(), forKey: "utm")
         return data
     }
    
    public func getSessionSchema(isFirstSession: Bool) -> NSMutableDictionary {
        let newSession = NSMutableDictionary()
        newSession.setValue(CommonUtil.generateUUID(), forKey: "id")
        newSession.setValue(Int((Date.currentTimeMillis)), forKey: "startTime")
        newSession.setValue(30, forKey: "sessionSpan") //30 Mins
        newSession.setValue(1800000, forKey: "expiryTime") //30 Mins in MilliSeconds
        newSession.setValue(isFirstSession, forKey: "firstSession")
        return newSession
    }
    
   public func getJSONForServer() -> NSMutableDictionary {
        
        let evtData = NSMutableDictionary()
        
        evtData.setValue(self.getAppVersionCode(), forKey: "appVersionCode")
        evtData.setValue(self.getAppVersionName(), forKey: "appVersionName")
        
        evtData.setValue(self.getOsName(), forKey: "osName")
        evtData.setValue(self.getOsVersion(), forKey: "osVersion")
        evtData.setValue(self.getLanguage(), forKey: "language")
        
        // Device data
        evtData.setValue("IOS", forKey: "platform")
        evtData.setValue(self.getDeviceType(), forKey: "deviceType")
        evtData.setValue(self.getManufacturer(), forKey: "deviceManufacturer")
        evtData.setValue(self.getModel(), forKey: "deviceModel")
        evtData.setValue(self.getCarrier(), forKey: "deviceCarrier")
        
        // SDK Version Code
        evtData.setValue(self.getSdkVersion(), forKey: "sdkVersion")
        
        return evtData
    }
    
    private class DeviceCachedInfo {
        
        fileprivate var deviceId : String?
        fileprivate var deviceType : String?
        fileprivate var appVersionCode: Int?
        fileprivate var appVersionName : String?
        fileprivate var osName : String?
        fileprivate var osVersion : String?
        fileprivate var language : String?
        fileprivate var manufacturer : String?
        fileprivate var model : String?
        fileprivate var carrier : String?
        fileprivate var countryCode : String?
        fileprivate var sdkVersion : String?
        fileprivate var notificationsEnabled : Bool?
        
        private let device          = UIDevice.current
                
        init() {
            deviceId                = self.getDeviceId()
            deviceType              = self.getDeviceType()
            appVersionName          = self.getAppVersionName()
            appVersionCode          = self.getAppVersionCode()
            osName                  = self.getOsName()
            osVersion               = self.getOsVersion()
            manufacturer            = self.getManufacturer()
            model                   = self.getModelName()
            carrier                 = self.getCarrier()
            language                = self.getLanguage()
            countryCode             = self.getCountryCode()
            sdkVersion              = self.getSdkVersion()
            notificationsEnabled    = self.getNotificationEnabledForUser()
        }
        
        // Get Device Id
        private func getDeviceId() -> String {
            // If not found, create deviceid and put to instance preferences
            // Read device id from instance prefs
            var deviceId = StorageHelper.getDeviceId
            
            // If device id not found, generate device id and store in pref
            if (deviceId == nil) {
                // If not found, create deviceid and put to instance preferences
                deviceId = CommonUtil.generateUUID()
                StorageHelper.getDeviceId = deviceId
            }
            return deviceId!
        }
        
        // Get OS Name
        private func getOsName() -> String {
            let systemName = device.systemName
            return systemName
        }
        
        private func getDeviceType() -> String {
            let type = device.model
            return type
        }
        
        private func getLanguage() -> String {
            if let langStr = Locale.current.languageCode{
                return langStr
            }
            return ""
        }
        
        private func getAppVersionName() -> String {
            let version = Bundle.main.versionNumber
            return version
        }
        
        private func getAppVersionCode() -> Int {
            let build = Int(Bundle.main.buildNumber)!
            return build
        }
        
        private func getOsVersion() -> String {
            let systemVersion = device.systemVersion
            let concatStr = self.getOsName() + " " + systemVersion
            return concatStr
        }
        
        private func getManufacturer() -> String {
            return "Apple"
        }
        
        private func getModelName() -> String {
            let modelName =  UIDevice.modelName /* see the extension */
            return  modelName
        }
        
        private func getCarrier() -> String {
            let networkInfo = CTTelephonyNetworkInfo()
            if #available(iOS 12.0, *) {
                if let carrier  = networkInfo.serviceSubscriberCellularProviders{
                    return carrier.first?.value.carrierName ?? "No Carrier"
                }
            }else {
                // Fallback on earlier versions
                if let carrierName = networkInfo.subscriberCellularProvider?.carrierName{
                    return carrierName
                }
            }
            return "No Carrier"
        }
        
        private func getCountryCode() -> String {
            
            let networkInfo = CTTelephonyNetworkInfo()
            if #available(iOS 12.0, *) {
                let carrier  = networkInfo.serviceSubscriberCellularProviders
                debugPrint("getCountryCode:",carrier as Any)
            }else {
                // Fallback on earlier versions
                if let isoCountryCode = networkInfo.subscriberCellularProvider?.isoCountryCode{
                    return isoCountryCode
                }
            }
            return ""
        }
        
        private func getSdkVersion() -> String {
            let sdkVersion = Bundle(for: type(of: self)).versionNumber
            return sdkVersion.replacingOccurrences(of: ".", with: "")
        }
        
        private func getNotificationEnabledForUser() -> Bool {
            var isEnable: Bool = false
            if #available(iOS 10.0, *) {
                let current = UNUserNotificationCenter.current()
                current.getNotificationSettings(completionHandler: { settings in
                    
                    switch settings.authorizationStatus {
                    case .authorized, .provisional:
                        isEnable = true
                        break
                    case .notDetermined, .denied:
                        break
                    @unknown default:
                        break
                    }
                })
            } else {
                // Fallback on earlier versions
                if UIApplication.shared.isRegisteredForRemoteNotifications {
                    isEnable = true
                }
            }
            return isEnable
        }
        
    }
}
