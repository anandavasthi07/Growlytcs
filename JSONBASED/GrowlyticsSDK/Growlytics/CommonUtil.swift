//
//  CommonUtil.swift
//  Growlytics
//
//  Created by Pradeep Singh on 05/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation
import SystemConfiguration

var globalUDID = ""
class CommonUtil {

    static func generateUUID() -> String{
        if !globalUDID.isEmpty {
            return globalUDID
        } else {
            print("UUID Generated")
            globalUDID = "GRW_" + UUID().uuidString.replacingOccurrences(of: "-", with: "")
            return globalUDID
        }
        
    }
    
    static func differenceBetweenTime(startTimestamp: Int, endTimestamp: Int) -> Float {
        let diff = endTimestamp - startTimestamp
        let minutes = Float(diff) / Float(60000)
        return minutes
    }

    static func isNetworkOnline() -> Bool{
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            Logger.instance.info(suffix: "Network-Check", message: "Failed to check network availablity.")
            return false
        }

        /* Only Working for WIFI
        let isReachable = flags == .reachable
        let needsConnection = flags == .connectionRequired

        return isReachable && !needsConnection
        */

        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        if !ret{
            Logger.instance.info(suffix: "Network-Check", message: "Device is not connected with internet.")
        }
        return ret

    }
}
