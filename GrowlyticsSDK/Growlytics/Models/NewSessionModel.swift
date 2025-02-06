//
//  NewSessionModel.swift
//  Growlytics
//
//  Created by Ankit Singh  on 13/03/23.
//  Copyright © 2023 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation

class NewSessionModel: Identifiable {
    public var id               : String?
    public var sid              : String?
    public var data             : NSDictionary?
    public var session          : NSDictionary?
    public var meta             : NSDictionary?
    public var device           : NSDictionary?
    public var timestamp        : Int?
    public var eventTimestamp   : Int?
    
    init() {}

    public func toString() -> String  {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(self.id, forKey: "id")
        dictionary.setValue(self.sid, forKey: "sid")
        dictionary.setValue(self.data, forKey: "data")
        dictionary.setValue(self.session, forKey: "session")
        dictionary.setValue(self.meta, forKey: "meta")
        dictionary.setValue(self.device, forKey: "device")
        dictionary.setValue(self.timestamp, forKey: "timestamp")
        dictionary.setValue(self.eventTimestamp, forKey: "eventTimestamp")
        
        debugPrint("NewSessionModel: ",dictionary)
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString!
        } catch let error {
            Logger.instance.info(suffix: "New Session-Stringify",
                                 message: "Failed to stringify new session.",
                                 error: error)
            // Ignore
            return ""
        }
    }
    
    static func fromDictonary(dict: [String: Any]) -> NewSessionModel {
        let newSession = NewSessionModel()
        newSession.id = dict["id"] as? String
        newSession.sid = dict["sid"] as? String
        newSession.data = dict["data"] as? NSDictionary
        newSession.session = dict["session"] as? NSDictionary
        newSession.device = dict["device"] as? NSDictionary
        newSession.meta = dict["meta"] as? NSDictionary
        newSession.timestamp = dict["timestamp"] as? Int
        newSession.eventTimestamp = dict["eventTimestamp"] as? Int
        return newSession
    }

    static func fromJson(deviceData: String ) -> NewSessionModel? {
        do {
            let jsonData = deviceData.data(using: .utf8)
            let dictionary = try JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves)
            debugPrint("NewSessionJson: ", dictionary as Any)
            
            if let dict = dictionary as? [String: Any] {

                return fromDictonary(dict: dict)
            }
        } catch let error {
            Logger.instance.info(suffix: "NewSessionParse", message: "Failed to parse newSession data.", error: error)
        }
        return nil
    }
}
