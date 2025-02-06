//
//  LogoutModel.swift
//  Growlytics
//
//  Created by Ankit Singh  on 17/03/23.
//  Copyright © 2023 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation

class LogoutModel {
    public var id               : String?
    public var sid              : String?
    public var session          : NSDictionary?
    public var meta             : NSDictionary?
    public var device           : NSDictionary?
    public var timestamp        : Int?
    public var eventTimestamp   : Int?
    
    init() {
    }

    public func toString() -> String  {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(self.id, forKey: "id")
        dictionary.setValue(self.sid, forKey: "sid")
        dictionary.setValue(self.session, forKey: "session")
        dictionary.setValue(self.meta, forKey: "meta")
        dictionary.setValue(self.device, forKey: "device")
        dictionary.setValue(self.timestamp, forKey: "timestamp")
        dictionary.setValue(self.eventTimestamp, forKey: "eventTimestamp")
        
        debugPrint("LogoutModel: ",dictionary)
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString!
        } catch let error {
            Logger.instance.info(suffix: "Event-Stringify",
                                 message: "Failed to stringify logout event.",
                                 error: error)
            // Ignore
            return ""
        }
    }

    static func fromJson(logoutData: String ) -> LogoutModel? {
        do {
            let jsonData = logoutData.data(using: .utf8)
            let dictionary = try JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves)
            debugPrint("LogoutData logoutDataInfoJson: ", dictionary as Any)
            
            if let dict = dictionary as? [String: Any] {
                let logout = LogoutModel()
                logout.id = dict["id"] as? String
                logout.sid = dict["sid"] as? String
                logout.session = dict["session"] as? NSDictionary
                logout.device = dict["device"] as? NSDictionary
                logout.meta = dict["meta"] as? NSDictionary
                logout.timestamp = dict["timestamp"] as? Int
                logout.eventTimestamp = dict["eventTimestamp"] as? Int


                return logout
            }
        } catch let error {
            Logger.instance.info(suffix: "EventParse", message: "Failed to parse login event.", error: error)
        }
        return nil
    }
}
