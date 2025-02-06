//
//  DeviceInfoModel.swift
//  Growlytics
//
//  Created by Ankit Singh  on 10/03/23.
//  Copyright © 2023 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation

class DeviceInfoModel: Identifiable {
    public var id               : String?
    public var device           : NSDictionary?
    public var meta             : NSDictionary?
    public var timestamp        : Int?
    public var eventTimestamp   : Int?
    
    init() {
    }

    public func toString() -> String  {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(self.id, forKey: "id")
        dictionary.setValue(self.device, forKey: "device")
        dictionary.setValue(self.meta, forKey: "meta")
        dictionary.setValue(self.timestamp, forKey: "timestamp")
        dictionary.setValue(self.eventTimestamp, forKey: "eventTimestamp")
        
        debugPrint("DeviceInfoModel: ",dictionary)
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString!
        } catch let error {
            Logger.instance.info(suffix: "DeviceInfo-Stringify",
                                 message: "Failed to stringify deviceInfo.",
                                 error: error)
            // Ignore
            return ""
        }
    }
    
    static func fromDictionary(dict: [String: Any]) -> DeviceInfoModel {
        let deviceInfo = DeviceInfoModel()
        deviceInfo.id = dict["id"] as? String
        deviceInfo.device = dict["device"] as? NSDictionary
        deviceInfo.meta = dict["meta"] as? NSDictionary
        deviceInfo.timestamp = dict["timestamp"] as? Int
        deviceInfo.eventTimestamp = dict["eventTimestamp"] as? Int
        return deviceInfo
    }

    static func fromJson(deviceData: String ) -> DeviceInfoModel? {
        do {
            let jsonData = deviceData.data(using: .utf8)
            let dictionary = try JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves)
            debugPrint("DeviceDataInfoJson: ", dictionary as Any)
            
            if let dict = dictionary as? [String: Any] {
                return fromDictionary(dict: dict)
            }
        } catch let error {
            Logger.instance.info(suffix: "DeviceInfoParse", message: "Failed to parse deviceInfo.", error: error)
        }
        return nil
    }
}
