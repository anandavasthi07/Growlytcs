//
//  AppInstallReceiver.swift
//  Growlytics
//
//  Created by Pradeep Singh on 10/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation

class AppInstallReceiver{
    
    // Check the app is launched first time or not.
    class func checkAppInstalled() {
        let versionOfLastRun = UserDefaults.standard.object(forKey: Constants.lastAppVersion) as? String

        if versionOfLastRun == nil {
            // Track app installed
            Analytics.getInstance().trackAppInstalled()
        }
    }
    
    // Check the udid is added or not.
    class func checkAppforUdid() {
        let udid = UserDefaults.standard.object(forKey: Constants.deviceUdid) as? String

        if udid == nil {
            // Track app installed
            EventProcessor.getInstance().trackDeviceRegister()
        } else {
            globalUDID = udid ?? ""
        }
    }
    
}
