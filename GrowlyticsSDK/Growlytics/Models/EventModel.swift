//
//  Event.swift
//  Growlytics
//
//  Created by Pradeep Singh on 08/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation

class EventModel: Identifiable {
    public var id               : String?
    public var sid              : String?
    public var event            : NSDictionary?
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
        dictionary.setValue(self.event, forKey: "event")
        dictionary.setValue(self.session, forKey: "session")
        dictionary.setValue(self.meta, forKey: "meta")
        dictionary.setValue(self.device, forKey: "device")
        dictionary.setValue(self.timestamp, forKey: "timestamp")
        dictionary.setValue(self.eventTimestamp, forKey: "eventTimestamp")
                
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

    static func fromDictionary(dictionary: [String: Any] ) -> EventModel {
            debugPrint("EventData eventDataInfoJson: ", dictionary as Any)
            
                let event = EventModel()
                event.id = dictionary["id"] as? String
                event.sid = dictionary["sid"] as? String
                event.event = dictionary["event"] as? NSDictionary
                event.session = dictionary["session"] as? NSDictionary
                event.device = dictionary["device"] as? NSDictionary
                event.meta = dictionary["meta"] as? NSDictionary
                event.timestamp = dictionary["timestamp"] as? Int
                event.eventTimestamp = dictionary["eventTimestamp"] as? Int

                return event
      
    }
    static func fromJson(eventData: String ) -> EventModel? {
        do {
            let jsonData = eventData.data(using: .utf8)
            let dictionary = try JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves)
            debugPrint("EventData eventDataInfoJson: ", dictionary as Any)
            
            if let dict = dictionary as? [String: Any] {
                return fromDictionary(dictionary: dict)
            }
        } catch let error {
            Logger.instance.info(suffix: "EventParse", message: "Failed to parse event.", error: error)
        }
        return nil
    }
}
