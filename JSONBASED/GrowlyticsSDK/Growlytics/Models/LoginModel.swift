//
//  LoginModel.swift
//  Growlytics
//
//  Created by Ankit Singh  on 15/03/23.
//  Copyright © 2023 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation

class LoginModel: Identifiable {
    public var id               : String?
    public var user             : NSDictionary?
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
        dictionary.setValue(self.user, forKey: "user")
        dictionary.setValue(self.session, forKey: "session")
        dictionary.setValue(self.meta, forKey: "meta")
        dictionary.setValue(self.device, forKey: "device")
        dictionary.setValue(self.timestamp, forKey: "timestamp")
        dictionary.setValue(self.eventTimestamp, forKey: "eventTimestamp")
        
        debugPrint("LoginModel: ",dictionary)
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString!
        } catch let error {
            Logger.instance.info(suffix: "Event-Stringify",
                                 message: "Failed to stringify login event.",
                                 error: error)
            // Ignore
            return ""
        }
    }
    
    static func fromDictionary(dict: [String: Any]) -> LoginModel {
        let login = LoginModel()
        login.id = dict["id"] as? String
        login.user = dict["user"] as? NSDictionary
        login.session = dict["session"] as? NSDictionary
        login.device = dict["device"] as? NSDictionary
        login.meta = dict["meta"] as? NSDictionary
        login.timestamp = dict["timestamp"] as? Int
        login.eventTimestamp = dict["eventTimestamp"] as? Int
        return login
    }

    static func fromJson(loginData: String ) -> LoginModel? {
        do {
            let jsonData = loginData.data(using: .utf8)
            let dictionary = try JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves)
            debugPrint("LoginData loginDataInfoJson: ", dictionary as Any)
            
            if let dict = dictionary as? [String: Any] {
                return fromDictionary(dict: dict)
            }
        } catch let error {
            Logger.instance.info(suffix: "EventParse", message: "Failed to parse login event.", error: error)
        }
        return nil
    }
}

