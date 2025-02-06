//
//  UriUtil.swift
//  Growlytics
//
//  Created by Pradeep Singh on 12/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation

final class UriUtil {
    
    static func parseUtmInfo(_ url: URL?) -> NSDictionary{
        
        let utmInfo = NSMutableDictionary()
        // Don't care for null values - they won't be added anyway
        let source = readQueryStringValue("utm_source", url)
        let medium = readQueryStringValue("utm_medium", url)
        let campaign = readQueryStringValue("utm_campaign", url)
        
        utmInfo.setValue(source, forKey: "us")
        utmInfo.setValue(medium, forKey: "um")
        utmInfo.setValue(campaign, forKey: "uc")
        
        Logger.instance.info(message: "Utm data: \(utmInfo)")
        return utmInfo
    }
    
    private static func readQueryStringValue(_ queryParamaterName: String, _ url: URL?) -> String? {
        
        if url == nil{ return nil }
        guard let urlComponent = URLComponents(string: url!.absoluteString) else { return nil }
        if let value:String = urlComponent.queryItems?.first(where: { $0.name == queryParamaterName })?.value{
            if value.count > Constants.MAX_VALUE_LENGTH{
                return String(value.prefix(Constants.MAX_VALUE_LENGTH))
            }else{
                return value
            }
        }
        return nil
    }
}
