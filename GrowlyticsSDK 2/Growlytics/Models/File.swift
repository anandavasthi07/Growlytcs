//
//  File.swift
//  Growlytics
//
//  Created by Ankit Singh  on 28/03/23.
//  Copyright © 2023 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation

class EventModelOld {
    public var id               : String?
    public var clientCustomerId : String?
    public var sessionId        : String?
    public var waitForSession   : Bool = true
    public var name             : String?
    public var info             : NSDictionary?
    public var eventType        : EventType?
    public var eventTime        : Int?
    
    init() {
    }

    public func toString() -> String  {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(self.id, forKey: "id")
        dictionary.setValue(self.sessionId, forKey: "sessionId")
        dictionary.setValue(self.clientCustomerId, forKey: "clientCustomerId")
        dictionary.setValue(self.waitForSession, forKey: "waitForSession")
        dictionary.setValue(self.name, forKey: "eventName")
        dictionary.setValue(self.info, forKey: "info")
        dictionary.setValue(self.eventType?.rawValue, forKey: "eventType")
        dictionary.setValue(self.eventTime, forKey: "eventTime")
        
        debugPrint("EventModel: ",dictionary)
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString!
        } catch let error {
            Logger.instance.info(suffix: "Event-Stringify",
                                 message: "Failed to stringify event.",
                                 error: error)
            // Ignore
            return ""
        }
    }

    static func fromJson(eventData: String ) -> EventModelOld? {
        do {
            let jsonData = eventData.data(using: .utf8)
            let dictionary = try JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves)
            debugPrint("EventData eventDataInfoJson: ", dictionary as Any)
            
            if let dict = dictionary as? [String: Any] {
                let event = EventModelOld()
                event.id = dict["id"] as? String
                event.sessionId = dict["sessionId"] as? String
                event.clientCustomerId = dict["clientCustomerId"] as? String
                event.waitForSession = dict["waitForSession"] as? Bool ?? true

                event.name = dict["eventName"] as? String
                event.info = dict["info"] as? NSDictionary
                event.eventType = EventType(rawValue: dict["eventType"] as! String)
                event.eventTime = dict["eventTime"] as? Int

                return event
            }
        } catch let error {
            Logger.instance.info(suffix: "EventParse", message: "Failed to parse event.", error: error)
        }
        return nil
    }
}
