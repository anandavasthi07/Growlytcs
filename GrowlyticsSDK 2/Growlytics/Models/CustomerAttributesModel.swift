//
//  CustomerAttributesModel.swift
//  Growlytics
//
//  Created by Ankit Singh  on 18/03/23.
//  Copyright © 2023 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation

class CustomerAttributesModel {
    public var id               : String?
    public var sid              : String?
    public var data             : [NSDictionary]?
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
        dictionary.setValue(self.data, forKey: "data")
        dictionary.setValue(self.session, forKey: "session")
        dictionary.setValue(self.meta, forKey: "meta")
        dictionary.setValue(self.device, forKey: "device")
        dictionary.setValue(self.timestamp, forKey: "timestamp")
        dictionary.setValue(self.eventTimestamp, forKey: "eventTimestamp")
                
        debugPrint("CustomerAttributes: ",dictionary)
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString!
        } catch let error {
            Logger.instance.info(suffix: "Event-Stringify",
                                 message: "Failed to stringify Customer Attributes.",
                                 error: error)
            // Ignore
            return ""
        }
    }

    static func fromJson(customerAttributesData: String ) -> CustomerAttributesModel? {
        do {
            let jsonData = customerAttributesData.data(using: .utf8)
            let dictionary = try JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves)
            debugPrint("customerAttributesDataJson: ", dictionary as Any)
            
            if let dict = dictionary as? [String: Any] {
                let customerAttributes = CustomerAttributesModel()
                customerAttributes.id = dict["id"] as? String
                customerAttributes.sid = dict["sid"] as? String
                customerAttributes.data = dict["data"] as? [NSDictionary]
                customerAttributes.session = dict["session"] as? NSDictionary
                customerAttributes.device = dict["device"] as? NSDictionary
                customerAttributes.meta = dict["meta"] as? NSDictionary
                customerAttributes.timestamp = dict["timestamp"] as? Int
                customerAttributes.eventTimestamp = dict["eventTimestamp"] as? Int

                return customerAttributes
            }
        } catch let error {
            Logger.instance.info(suffix: "CustomerAttributesParse", message: "Failed to parse Customer Attributes.", error: error)
        }
        return nil
    }
}
