//
//  ValidationUtil.swift
//  Growlytics
//
//  Created by Pradeep Singh on 04/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation

class ValidationUtil {

    private static var restrictedEventNames: [String] = ["GrwNotification Clicked",
            "GrwNotification Viewed", "UTM Visited", "GrwNotification Sent", "App Launched",
            "App Uninstalled", "GrwNotification Bounced"]

    static func validateEventAttributes(_ eventAttributes : [String : Any] ) -> String? {

        var errors = [String]()
        let eventAttributes = eventAttributes as NSDictionary
        for key in eventAttributes.allKeys {

            // Validate attribute key.
            let result = self.validateAttributeKey(attributeKey: key as? String)
            if result != nil {
                errors.append("Invalid attribute key, \(result!)")
            }

            // Validate attribute value
            let value = eventAttributes.value(forKey: key as! String)
            if (value == nil) {
                continue
            }

            // If it's any type of number, send it back
            if (value is Int //"integer"
                    || value is Float //"float"
                    || value is Bool //"boolean"
                    || value is Double //"double"
                    || value is Date) //"date"
                    {
                continue
            }
            else if value is String {
                let stringValue =  value as! String
                if (stringValue.count > Constants.MAX_VALUE_LENGTH) {
                    errors.append("Invalid attribute value, attribute string value can not exceed \( Constants.MAX_VALUE_LENGTH) characters.");
                }
            }
            else {
                errors.append("Attribute value can only be of type: String, Boolean, Long, Integer, Float, Double, or Date.")
            }
        }

        if(errors.count > 0){
            var error = "\(errors.count) attributes are invalid."
            error += " | \(errors)"
            return error
        }

        return nil
    }

    private static func validateAttributeKey(attributeKey: String?) -> String? {

        // Check if its empty
        guard let key = attributeKey, !key.isEmpty else {
            return "Attribute key can not be empty or null."
        }
    
        // Check if it exceeds allowed characters
        if (key.count > Constants.MAX_KEY_LENGTH) {
            return "Attribute key can not be greater than \(Constants.MAX_KEY_LENGTH) characters.";
        }

        return nil
    }

    static func validateEventName(_ eventName : String?) -> String?{

        // Check if its empty
        guard let event = eventName, !event.isEmpty else {
            return "Event name can not be empty or null."
        }

        // Check if it exceeds allowed characters
        if (event.count > Constants.MAX_KEY_LENGTH) {
            return "Event name can not be greater than \(Constants.MAX_KEY_LENGTH) characters."
        }

        // Reserved event name are not allowed.
        for x in self.restrictedEventNames {
            if event.caseInsensitiveCompare(x) == .orderedSame{
                return "\(event) is a restricted event name. Please read docs at docs.growlytics.in to see all restricted events."
            }
        }
        return nil
    }

    static func validateCustomerId(customerId : String?) -> String?{

        // Null not allowed
        if (customerId == nil) {
            return "Customer Id can not be null."
        }

        // Can not exceed 40 characters
        if (customerId!.count > Constants.MAX_CUSTOMER_ID_LENGTH) {
            return "Customer Id can not be greater than \(Constants.MAX_CUSTOMER_ID_LENGTH) characters."
        }
        return nil
    }
}
