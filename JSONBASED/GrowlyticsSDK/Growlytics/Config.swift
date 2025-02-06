//
//  Config.swift
//  Growlytics
//
//  Created by Pradeep Singh on 05/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation

class Config {
    
    private var apiKey              : String?
    private var env                 : Bool?
    private static var instance     : Config?
    private var isDisabled          : Bool      = false
    private var debug               : Bool      = false
    private var host                            = "https://dcq-india-region-prod-u2u533qbxa-as.a.run.app" // prod server //"https://grw-sdk-mobile.ngrok.dev"//local server 
    //private var fcmSenderId         : String?
    private var notificationIcon    : String?
    
    static func getInstance() -> Config {
        if (instance == nil) {
            //Singleton instance. Initializing Config.
            instance =  Config()
        }
        return instance!
    }
    
    func getApiKey() -> String {
        return self.apiKey ?? ""
    }
    
    func getEnvironment() -> String {
        return self.env ?? false ? "test" : "production"
    }
    
    func isDisable() -> Bool{
        return self.isDisabled
    }
    
    func setDisabled(_ disabled : Bool) {
        self.isDisabled = disabled
    }
    
    func getNotificationIcon() -> String{
        return self.notificationIcon ?? ""
    }
    
    func getDebug() -> Bool{
        return self.debug
    }
    
    func getHost() -> String {
        return self.host
    }
    
//    func getFcmSenderId() -> String {
//        return self.fcmSenderId ?? ""
//    }
    
    private init() {
        
        self.apiKey     = Bundle.main.infoDictionary?[Constants.MANIFEST_API_KEY] as? String
        self.isDisabled = true == Bundle.main.infoDictionary?[Constants.MANIFEST_DISABLED] as? Bool
        self.notificationIcon  = Bundle.main.infoDictionary?[Constants.MANIFEST_NOTIFICATION_ICON] as? String
        
        // Read env
        self.env = Bundle.main.infoDictionary?[Constants.MANIFEST_GLYTICS_TEST_MODE] as? Bool
    
        // Set debug info
        self.debug = true == Bundle.main.infoDictionary?[Constants.MANIFEST_DEBUG] as? Bool
        if (!debug) {
            Logger.instance.setEnabled(true)
        }
        
//        self.fcmSenderId = Bundle.main.infoDictionary?[Constants.LABEL_FCM_SENDER_ID] as? String
//        if (self.fcmSenderId != nil) {
//            self.fcmSenderId = fcmSenderId?.replacingOccurrences(of: "id", with: "")
//        }
        
        let inputHost = Bundle.main.infoDictionary?[Constants.MANIFEST_HOST] as? String
        if (inputHost != nil) {
            self.host = inputHost!
        }
    }

}

